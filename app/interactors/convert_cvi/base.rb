module ConvertCvi
  class Base < ApplicationInteractor
    def call
      @cvi_statement = CviStatement.find(context.cvi_statement_id)
      @activity_open_from = cvi_statement.campaign.harvest_year
      check_activities
      ActiveRecord::Base.transaction do
        begin
          cvi_statement.cvi_land_parcels.each do |cvi_land_parcel|
            ConvertCviLandParcel.call(cvi_land_parcel, activity_open_from)
          end
        rescue StandardError => e
          binding.pry
          context.fail!(error: e.message)
        end
      end
    end

    private

    attr_reader :cvi_statement, :activity_open_from

    def check_activities
      return unless cvi_statement.cvi_land_parcels.pluck(:activity_id).include?(nil)

      context.fail!(error: :missing_activity_on_cvi_land_parcel)
    end
  end
end
