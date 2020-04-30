module NamingFormats
  module LandParcels
    class ChangeLandParcelsNamesInteractor < ApplicationInteractor
      def call
        change_land_parcels_name
      end

      private

      def change_land_parcels_name
        LandParcel.all.each do |land_parcel|
          result = NamingFormats::LandParcels::BuildActivityProductionNameInteractor
                       .call(activity_production: land_parcel.activity_production)

          land_parcel.update_attribute(:name, result.build_name) if result.success?
          context.fail!(result.error) if result.fail?
        end
      end
    end
  end
end
