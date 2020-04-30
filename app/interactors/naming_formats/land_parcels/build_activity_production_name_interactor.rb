module NamingFormats
  module LandParcels
    class BuildActivityProductionNameInteractor < ApplicationInteractor

      def call
        @activity_production = context.activity_production
        build_land_parcel_name
      end

      def build_land_parcel_name
        begin
          # puts "--BuildActivityProductionNameInteractor | NamingFormatLandParcel--".inspect.red
          # puts naming_format_fields_names.inspect.red
          context.build_name = NamingFormats::LandParcels::BuildNamingService
                        .new(cultivable_zone: @activity_production.cultivable_zone,
                             activity: @activity_production.activity,
                             campaign: @activity_production.campaign,
                             season: @activity_production.season)
                        .perform(field_values: naming_format_fields_names)

          rank_number = :rank.t(number: @activity_production.rank_number)
          # puts "--BuildActivityProductionNameInteractor--".inspect.red
          # puts context.build_name.inspect.red
          context.build_name.concat(" #{rank_number}")
        rescue StandardError => exception
          context.fail!(error: exception.message)
        end
      end

      private

      def naming_format_fields_names
        NamingFormatLandParcel.last.fields.map(&:field_name)
      end
    end
  end
end
