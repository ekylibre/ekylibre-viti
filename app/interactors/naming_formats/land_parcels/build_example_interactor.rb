module NamingFormats
  module LandParcels
    class BuildExampleInteractor < ApplicationInteractor
      # see https://github.com/collectiveidea/interactor

      attr_reader :example, :field_values

      def call
        @field_values = context.fields_values
        method_one
      end

      def method_one
        context.example = NamingFormats::LandParcels::BuildNamingService
                   .new(cultivable_zone: CultivableZone.first,
                        activity: Activity.first,
                        campaign: Campaign.first,
                        season: ActivitySeason.first)
                   .perform(field_values: @field_values)
      rescue StandardError => exception
        context.fail!(exception.message)
      end

      private

      # private method

    end
  end
end
