class GroupCviCultivableZones < ApplicationInteractor
  def call
    check_if_groupable
    generate_cvi_land_parcels unless all_cvi_land_parcels_created? || none_cvi_land_parcel_created?
    ActiveRecord::Base.transaction do
      create_new_record
      create_associated_cvi_cadastral_plants
      create_associated_locations
      create_associated_cvi_land_parcels
      destroy_grouped_records
    end
  end

  def all_cvi_land_parcels_created?
    context.cvi_cultivable_zones.all? { |ccz| ccz.cvi_land_parcels.any? }
  end

  def none_cvi_land_parcel_created?
    context.cvi_cultivable_zones.none? { |ccz| ccz.cvi_land_parcels.any? }
  end

  def generate_cvi_land_parcels
    context.cvi_cultivable_zones.select { |ccz| ccz.cvi_land_parcels.empty? }.each do |cvi_cultivable_zone|
      GenerateCviLandParcels.call(cvi_cultivable_zone: cvi_cultivable_zone) if cvi_cultivable_zone.cvi_land_parcels.empty?
    end
  end

  def check_if_groupable
    @new_shape = CviCultivableZone.select('St_AStext(
                                            ST_Buffer(
                                              ST_Union(
                                                ARRAY_AGG(
                                                  ST_Buffer(shape,0.000001,\'join=mitre\')
                                                )
                                              ),-0.000001,\'join=mitre\')
                                            ) AS shape')
                                  .where(id: context.cvi_cultivable_zones.collect(&:id))[0]
                                  .shape.to_rgeo.simplify(0.05)
    geometry_type = @new_shape.geometry_type
    unless geometry_type == RGeo::Feature::Polygon
      context.fail!(error: :can_not_group_cvi_cultivable_zones_no_intersection)
    end
  end

  private

  def create_new_record
    declared_area = context.cvi_cultivable_zones.collect(&:declared_area).sum
    name = context.cvi_cultivable_zones.collect(&:name).sort.join(', ')
    new_cvi_cultivable_zone = context.cvi_cultivable_zones.first.dup
    new_cvi_cultivable_zone.save!
    new_cvi_cultivable_zone.assign_attributes(name: name, shape: @new_shape, declared_area: declared_area)
    new_cvi_cultivable_zone.save!
    context.new_cvi_cultivable_zone = new_cvi_cultivable_zone
  end

  def create_associated_cvi_cadastral_plants
    cvi_cadastral_plants = CviCadastralPlant.where(cvi_cultivable_zone_id: context.cvi_cultivable_zones.collect(&:id))
    cvi_cadastral_plants.update_all(cvi_cultivable_zone_id: context.new_cvi_cultivable_zone.id)
  end

  def create_associated_locations
    locations = context.cvi_cultivable_zones.flat_map(&:locations)
    uniq_locations = locations.uniq { |r| [r.insee_number, r.locality] }
    uniq_locations.each do |location|
      location.update(localizable_id: context.new_cvi_cultivable_zone.id, localizable_type: 'CviCultivableZone')
    end
  end

  def create_associated_cvi_land_parcels
    cvi_land_parcels = context.cvi_cultivable_zones.flat_map(&:cvi_land_parcels)
    cvi_land_parcels.each do |cvi_land_parcel|
      cvi_land_parcel.update_column(:cvi_cultivable_zone_id, context.new_cvi_cultivable_zone.id)
    end
  end

  def destroy_grouped_records
    context.cvi_cultivable_zones.each{ |ccz| ccz.reload.destroy }
  end
end
