module Backend
  module ActivitiesControllerExt
    extend ActiveSupport::Concern

    included do
      before_action :find_vine_default_production_id, only: %i[show edit new]

      before_action :set_production_cycle_years, only: %i[update create]

      def set_production_cycle_years
        return unless permitted_params["production_started_on"].present? &&
                      permitted_params["production_stopped_on"].present? &&
                      permitted_params["production_campaign"].present?

        production_started_on = permitted_params["production_started_on"].to_date.change(year: 2000)
        permitted_params["production_started_on"] = production_started_on.to_s
        year = if permitted_params["production_campaign"] == "at_cycle_end"
                 2001
               else
                 2000
               end
        production_stopped_on = permitted_params["production_stopped_on"].to_date.change(year: year)
        permitted_params["production_stopped_on"] = production_stopped_on.to_s
      end

      def find_vine_default_production_id
        @vine_default_production_id = MasterProductionNature.find_by(specie: 'vitis')&.id
      end
    end
  end
end
