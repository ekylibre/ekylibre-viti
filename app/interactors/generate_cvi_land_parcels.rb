class GenerateCviLandParcels < ApplicationInteractor
  def call
    ActiveRecord::Base.transaction do
      cvi_cultivable_zone = context.cvi_cultivable_zone
      cvi_cadastral_plants = cvi_cultivable_zone.cvi_cadastral_plants
      cvi_cadastral_plants.each do |r|
        declared_area = r.area
        shape = r.shape.to_rgeo.simplify(0.05)

        cvi_land_parcel = CviLandParcel.create(
          name: r.cadastral_reference,
          designation_of_origin_id: r.designation_of_origin_id,
          vine_variety_id: r.vine_variety_id,
          declared_area: declared_area,
          inter_vine_plant_distance: r.inter_vine_plant_distance,
          inter_row_distance: r.inter_row_distance,
          state: r.state,
          shape: shape,
          cvi_cultivable_zone_id: cvi_cultivable_zone.id,
          planting_campaign: r.planting_campaign,
          land_modification_date: r.land_modification_date
        )
        cvi_land_parcel.cvi_cadastral_plants << r
        Location.create(localizable: cvi_land_parcel, locality: r.location.locality, registered_postal_zone_id: r.location.registered_postal_zone_id)
      end
    end
  end
end