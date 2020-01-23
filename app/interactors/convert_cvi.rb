class ConvertCvi < ApplicationInteractor
  
  def call
    @cvi_land_parcels = context.cvi_statement.cvi_land_parcels
    @activities = cvi_land_parcels.collect(&:activity)
    @campaign = context.cvi_statement.campaign

    cvi_land_parcels.each do |cvi_land_parcel|
      land_parcel = LandParcel.create(
        name: cvi_land_parcel.name,
        initial_shape: cvi_land_parcel.shape,
        variety: "land_parcel",
        variant_id: ProductNatureVariant.import_from_nomenclature(:land_parcel).id,
        nature_id: ProductNature.import_from_nomenclature(:land_parcel).id,
        category_id: ProductNatureCategory.import_from_nomenclature(:land_parcel).id,
      )

      cvi_cultivable_zone = cvi_land_parcel.cvi_cultivable_zone
      cultivable_zone = CultivableZone.create_with(
        name: cvi_cultivable_zone.name,
        shape: cvi_cultivable_zone.shape
      ).find_or_create_by(name: cvi_cultivable_zone.name)

      activity = cvi_land_parcel.activity
      ActivityProduction.create(
        campaign_id: campaign.id,
        support_id: land_parcel.id,
        activity_id: activity.id,
        cultivable_zone_id: cultivable_zone.id,
        size_value: land_parcel.initial_population,
        size_indicator_name: "net_surface_area",
        size_unit_name: "hectare",
        support_shape: land_parcel.initial_shape,
        started_on: activity.production_started_on.change(year: campaign.harvest_year - 1),
        stopped_on: activity.production_stopped_on.change(year: campaign.harvest_year)
      )
    end
  end

  private
  
  attr_accessor :cvi_land_parcels, :activities, :campaign
end