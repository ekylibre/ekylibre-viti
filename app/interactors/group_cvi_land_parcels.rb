class GroupCviLandParcels < ApplicationInteractor
  ATTRIBUTES = %i[designation_of_origin_id vine_variety_id inter_vine_plant_distance_value inter_row_distance_value planting_campaign state].freeze

  def call
    check_if_groupable
    ActiveRecord::Base.transaction do
      create_new_record
      create_associated_locations
      create_associated_land_parcel_rootstocks
      destroy_grouped_records
    end
  end

  def check_if_groupable
    @new_shape = CviLandParcel.select('St_AStext(ST_Buffer(ST_Union(ARRAY_AGG(ST_Buffer(shape,0.000001,\'join=mitre\'))),-0.000001,\'join=mitre\')) AS shape').where(id: context.cvi_land_parcels.collect(&:id))[0].shape.to_rgeo.simplify(0.05)
    geometry_type = @new_shape.geometry_type
    unless geometry_type == RGeo::Feature::Polygon
      context.fail!(error: ::I18n.t(:can_not_group_no_intersection, 
                                    name_pluralized: CviLandParcel.model_name.human.pluralize.downcase, 
                                    scope: [:notifications, :messages]))
    end
    attributes_with_differente_values = ATTRIBUTES.map do |a|
      a if context.cvi_land_parcels.collect { |r| r.try(a) }.compact.uniq.length > 1
    end
    context.fail!(error: :can_not_group_cvi_land_parcels, attributes: attributes_with_differente_values.compact) if attributes_with_differente_values.any?
  end

  private

  def create_new_record
    declared_area = context.cvi_land_parcels.collect(&:declared_area).sum
    calculated_area = Measure.new(@new_shape.area, :square_meter).convert(:hectare)
    @total_area = calculated_area
    name = context.cvi_land_parcels.collect(&:name).sort.join(', ')
    new_cvi_land_parcel = context.cvi_land_parcels.first.dup
    new_cvi_land_parcel.save!
    new_cvi_land_parcel.assign_attributes(name: name, declared_area: declared_area, shape: @new_shape)
    new_cvi_land_parcel.save!
    context.new_cvi_land_parcel = new_cvi_land_parcel
  end

  def create_associated_land_parcel_rootstocks
    land_parcel_rootstocks = context.cvi_land_parcels.flat_map(&:land_parcel_rootstocks)
    uniq_rootstock_ids = land_parcel_rootstocks.collect(&:rootstock_id).uniq

    if uniq_rootstock_ids.length > 1
      new_land_parcel_rootstock = uniq_rootstock_ids.map do |rootstock_id|
        new_land_parcel_rootstock = { area: nil, percentage: nil, rootstock_id: rootstock_id }
        rootstock_area = land_parcel_rootstocks.select { |r| r.rootstock_id == rootstock_id }.sum { |r| r.land_parcel.calculated_area * r.percentage }
        percentage = rootstock_area / @total_area
        { percentage: percentage, rootstock_id: rootstock_id, land_parcel: context.new_cvi_land_parcel }
      end
      LandParcelRootstock.create!(new_land_parcel_rootstock)
    else
      new_land_parcel_rootstock = land_parcel_rootstocks.first.dup
      new_land_parcel_rootstock.land_parcel = context.new_cvi_land_parcel
      new_land_parcel_rootstock.save!
    end
  end

  def create_associated_locations
    new_locations = context.cvi_land_parcels.flat_map(&:locations).uniq { |r| [r.registered_postal_zone_id, r.locality] }.map(&:dup)
    context.new_cvi_land_parcel.locations.create!(new_locations.map(&:attributes))
  end

  def destroy_grouped_records
    context.cvi_land_parcels.each(&:destroy)
  end
end