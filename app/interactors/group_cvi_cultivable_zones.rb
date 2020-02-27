class GroupCviCultivableZones < ApplicationInteractor
  def call
    check_if_groupable
    generate_cvi_land_parcels unless all_cvi_land_parcels_created? || none_cvi_land_parcel_created?
    ActiveRecord::Base.transaction do
      create_new_record
      update_associated_cvi_cadastral_plants
      update_associated_locations
      update_associated_cvi_land_parcels
      destroy_grouped_records
    end
  end

  private

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

  def new_shape
    @new_shape ||= CviCultivableZone.select('St_AStext(
                                            ST_Buffer(
                                              ST_Union(
                                                ARRAY_AGG(
                                                  ST_Buffer(shape,0.000001,\'join=mitre\')
                                                )
                                              ),-0.000001,\'join=mitre\')
                                            ) AS shape')
                                    .where(id: context.cvi_cultivable_zones.collect(&:id))[0]
                                    .shape.to_rgeo.simplify(0.05)
  end

  def check_if_groupable
    geometry_type = new_shape.geometry_type
    return if geometry_type == RGeo::Feature::Polygon

    context.fail!(error: ::I18n.t(:can_not_group_no_intersection,
                                  name_pluralized: CviCultivableZone.model_name.human(count: 2).downcase,
                                  scope: %i[notifications messages]))
  end

  def create_new_record
    declared_area = context.cvi_cultivable_zones.collect(&:declared_area).sum
    name = context.cvi_cultivable_zones.collect(&:name).sort.join(', ')
    new_cvi_cultivable_zone = context.cvi_cultivable_zones.first.dup
    new_cvi_cultivable_zone.assign_attributes(name: name, shape: @new_shape, declared_area: declared_area)
    new_cvi_cultivable_zone.save!
    context.new_cvi_cultivable_zone = new_cvi_cultivable_zone
  end

  def update_associated_cvi_cadastral_plants
    cvi_cadastral_plants = CviCadastralPlant.where(cvi_cultivable_zone_id: context.cvi_cultivable_zones.collect(&:id))
    cvi_cadastral_plants.update_all(cvi_cultivable_zone_id: context.new_cvi_cultivable_zone.id)
  end

  def update_associated_locations
    locations = Location.where(localizable_id: context.cvi_cultivable_zones.collect(&:id), localizable_type: 'CviCultivableZone').uniq
    locations.update_all(localizable_id: context.new_cvi_cultivable_zone.id)
  end

  def update_associated_cvi_land_parcels
    cvi_land_parcels = CviLandParcel.where(cvi_cultivable_zone_id: context.cvi_cultivable_zones.collect(&:id))
    cvi_land_parcels.update_all(cvi_cultivable_zone_id: context.new_cvi_cultivable_zone.id)
  end

  def destroy_grouped_records
    context.cvi_cultivable_zones.each { |ccz| ccz.reload.destroy }
  end
end
