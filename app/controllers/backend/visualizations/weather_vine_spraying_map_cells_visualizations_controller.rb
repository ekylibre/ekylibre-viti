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
        factory = RGeo::Geographic.simple_mercator_factory()

        visualization_face = params[:visualization]
        activity_production_ids = params[:activity_production_ids]
        campaign = params[:campaign]

        activity_productions = ActivityProduction.where(id: activity_production_ids)

        if activity_productions.any?

          activity_productions.includes(:activity, :campaign, :cultivable_zone, interventions: [:outputs, :participations, tools: :product, inputs: :product]).find_each do |support|

            # get all real interventions of vine protections during campaign
            interventions = support.interventions.real.of_category(:vine_protection)

            next unless support.support_shape && interventions.any?
            popup_content = []

            # for support

            # popup_content << {label: :campaign.tl, value: view_context.link_to(params[:campaigns.name, backend_campaign_path(params[:campaigns))}
            # popup_content << { label: ActivityProduction.human_attribute_name(:net_surface_area), value: support.human_support_shape_area }
            # popup_content << { label: ActivityProduction.human_attribute_name(:activity), value: view_context.link_to(support.activity_name, backend_activity_path(support.activity)) }

            last_intervention = interventions.order(started_at: :desc).first
            if last_intervention
              # TODO add a method in has_geometry to query (ST_Distance)
              # the distance between all analysis geolocation and a shape
              # and select the analysis nearest the shape

              # get the analysis with cumulated_rainfall near support shape at max 5 km from intervention stopped at and now
              rainfall_geo_analyses = Analysis.with_indicator(ind.name).geolocation_near(support.support_shape, 5000).between(last_intervention.stopped_at, Time.now)
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

            bottom_line = ''
            bottom_line << "<span>#{view_context.link_to(:see_more_details.tl, sensor.partner_url)}</span>" if sensor.partner_url.present?
            bottom_line << "<i class='icon icon-battery-alert' style='color: red;'></i>" if sensor.alert_on? 'battery_life'
            bottom_line << "<i class='icon icon-portable-wifi-off' style='color: red;'></i>" if sensor.alert_on? 'lost_connection'
            popup_lines << ("<div style='display: flex; justify-content: space-between'>" + bottom_line + '</div>').html_safe
            header_content = "<span class='sensor-name'>#{sensor.name}</span>#{view_context.lights(sensor.alert_status)}".html_safe
            s_items = {
              sensor_id: sensor.id,
              name: sensor.name,
              shape: s_analysis.geolocation,
              shape_color: '#' + Digest::MD5.hexdigest(sensor.model_euid)[0, 6].upcase,
              group: sensor.model_euid.camelize,
              popup: { header: header_content, content: popup_lines }
            }
            sensor_data << s_items

            filtered_a = rainfall_geo_analyses.where(sensor_id: ref_sensor_id).reorder(:analysed_at)
            start = filtered_a.first.analysed_at
            stop = filtered_a.last.analysed_at
            final_items = AnalysisItem.where(indicator_name: ind.name, analysis_id: filtered_a.pluck(:id))

            # compute distance between sensor and intervention shape
            ## support
            lat = support.support_shape.centroid.first
            lon = support.support_shape.centroid.last
            point_support = factory.point(lat, lon)
            ## sensor
            point_analysis = factory.point(filtered_a.first.geolocation.latitude, filtered_a.first.geolocation.longitude)
            distance_value = point_support.distance(point_analysis).round(2)
            distance = Measure.new(distance_value, :meter)

            next unless final_items.any?
            cumulated_rainfall = final_items.map{|f| f.value }.compact.sum

            # build popup
            popup_content << { label: :last_intervention.tl, value: view_context.link_to(last_intervention.name, backend_intervention_path(last_intervention)) }
            popup_content << { label: :date.tl , value: last_intervention.started_at.l }
            popup_content << { label: ind.human_name, value: cumulated_rainfall.l(precision: 2) } # #{:manual_period.tl(start: start.l, finish: stop.l)}
            popup_content << { label: "#{:sensors.tl} | #{distance.l(precision: 2)}", value: view_context.link_to(sensor.name, backend_sensor_path(sensor)) }

            item = {
              name: support.name,
              shape: support.support_shape,
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
            v.choropleth :cumulated_rainfall, :main, label: ind.human_name, unit: unit.symbol, stop_color: "#002AFF"
          end

        end

        respond_with config
      end
    end
  end
end
