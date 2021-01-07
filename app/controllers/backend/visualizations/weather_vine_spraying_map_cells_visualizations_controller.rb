module Backend
  module Visualizations
    class WeatherVineSprayingMapCellsVisualizationsController < Backend::VisualizationsController
      respond_to :json

      def show
        config = {}
        data = []
        sensor_data = []
        ind = Nomen::Indicator[:cumulated_rainfall]
        unit = Nomen::Unit.find(ind.unit)
        activity_production_ids = params[:activity_production_ids]

        activity_productions = ActivityProduction.where(id: activity_production_ids)

        if activity_productions.any?

          activity_productions.includes(:activity, :campaign, :cultivable_zone, interventions: [:outputs, :participations, tools: :product, inputs: :product]).find_each do |support|

            # get all real interventions of vine protections during campaign
            interventions = support.interventions.real.of_category(:vine_protection)

            support_shape = support.support_shape
            next unless support_shape && interventions.any?
            popup_content = []

            # for support

            # popup_content << {label: :campaign.tl, value: view_context.link_to(params[:campaigns.name, backend_campaign_path(params[:campaigns))}
            # popup_content << { label: ActivityProduction.human_attribute_name(:net_surface_area), value: support.human_support_shape_area }
            # popup_content << { label: ActivityProduction.human_attribute_name(:activity), value: view_context.link_to(support.activity_name, backend_activity_path(support.activity)) }

            last_intervention = interventions.order(started_at: :desc).first
            if last_intervention
              # get the analysis with cumulated_rainfall near support shape at max 5 km from intervention stopped at and now
              rainfall_geo_analyses = Analysis.with_indicator(ind.name)
                                              .geolocation_near(support_shape, 5000)
                                              .where(sensor_id: Sensor.nearest_of_and_within(support_shape, 5000).pluck(:id))
                                              .between(last_intervention.stopped_at, Time.now)
                                              .select('DISTINCT ON (analyses.sampled_at) *')
            end

            next unless rainfall_geo_analyses.any?
            # get only one sensor to avoid double or tripe sum for cumulated_rainfall
            ref_sensor_id = rainfall_geo_analyses.pluck(:sensor_id).uniq.first
            sensor = Sensor.find(ref_sensor_id) if ref_sensor_id

            # compute sensor data map
            s_analysis = sensor.analyses.last
            transmission = sensor.last_transmission_at
            popup_lines = []
            popup_lines << { label: sensor.human_attribute_name(:last_transmission_at), content: transmission.localize } if transmission.present?
            s_analysis.items.map do |item|
              next unless item.value.respond_to? :l
              popup_lines << { label: item.human_indicator_name, content: item.value.l }
            end

            popup_lines << render_to_string(partial: 'popup', locals: { sensor: sensor })
            header_content = view_context.content_tag(:span, sensor.name, class: 'sensor-name') + view_context.lights(sensor.alert_status)
            s_items = {
              sensor_id: sensor.id,
              name: sensor.name,
              shape: s_analysis.geolocation,
              shape_color: '#' + Digest::MD5.hexdigest(sensor.model_euid)[0, 6].upcase,
              group: sensor.model_euid.camelize,
              popup: { header: header_content, content: popup_lines }
            }
            sensor_data << s_items

            final_items = AnalysisItem.where(indicator_name: ind.name, analysis_id: rainfall_geo_analyses.collect(&:id))

            # compute distance between sensor and intervention shape
            sensor_position = rainfall_geo_analyses.take.geolocation
            shape = Charta.new_geometry(support_shape.to_rgeo.simplify(0))
            distance = Measure.new(shape.distance(sensor_position), :meter)

            next unless final_items.any?
            cumulated_rainfall = final_items.map{|f| f.value }.compact.sum

            # build popup
            popup_content << { label: :last_intervention.tl, value: view_context.link_to(last_intervention.name, backend_intervention_path(last_intervention)) }
            popup_content << { label: :date.tl , value: last_intervention.started_at.l }
            popup_content << { label: ind.human_name, value: cumulated_rainfall.l(precision: 2) } # #{:manual_period.tl(start: start.l, finish: stop.l)}
            popup_content << { label: "#{:sensors.tl} | #{distance.l(precision: 2)}", value: view_context.link_to(sensor.name, backend_sensor_path(sensor)) }

            item = {
              name: support.name,
              shape: support_shape,
              shape_color: support.activity.color,
              cumulated_rainfall: cumulated_rainfall.to_f,
              popup: { header: true, content: popup_content }
            }
            data << item
          end

          config = view_context.configure_visualization do |v|
            if sensor_data.present?
              v.serie :sensor_data, sensor_data
              v.point_group :sensors, :sensor_data
            end
            v.serie :main, data
            v.choropleth :cumulated_rainfall, :main, label: ind.human_name, unit: unit.symbol, stop_color: '#002AFF'
          end

        end

        respond_with config
      end
    end
  end
end
