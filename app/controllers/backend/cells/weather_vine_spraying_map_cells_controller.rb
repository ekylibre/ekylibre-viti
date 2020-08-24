module Backend
  module Cells
    class WeatherVineSprayingMapCellsController < Backend::Cells::BaseController
      def show
        @campaign = if params[:campaign_ids]
                       Campaign.find(params[:campaign_ids]).last
                     elsif params[:campaign_id]
                       Campaign.find(params[:campaign_id])
                     else
                       current_campaign
                     end

        @activity_production_ids = params[:activity_production_ids] if params[:activity_production_ids]
        @activity_production_ids = params[:activity_production_id] if params[:activity_production_id]

        ap = ActivityProduction.of_activity_families(:vine_farming).where.not(support_shape: nil)

        @activity_productions = (@activity_production_ids ? ap.where(id: @activity_production_ids) : ap.of_campaign(@campaign))

        @url_params = {
          activity_production_ids: @activity_productions.pluck(:id),
          campaign: @campaign,
          visualization: params[:visualization]
        }

      end
    end
  end
end
