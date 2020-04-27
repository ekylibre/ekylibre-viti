class GroupCviLandParcels < ApplicationInteractor
  ATTRIBUTES = %i[designation_of_origin_id vine_variety_id inter_vine_plant_distance_value inter_row_distance_value state activity_id].freeze

  def call
    check_if_groupable
    ActiveRecord::Base.transaction do
      create_new_record
      create_associated_locations
      set_associated_cvi_cadastral_plants
      set_main_rootstock
      set_main_campaign
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
      a if context.cvi_land_parcels.collect { |r| r.try(a) }.compact.uniq.length >= 1
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
    new_cvi_land_parcel.save!(context: :group_cvi_land_parcel)
    context.new_cvi_land_parcel = new_cvi_land_parcel
  end

  def set_associated_cvi_cadastral_plants
    context.cvi_land_parcels.flat_map(&:cvi_cadastral_plants).each do |cvi_cadastral_plant|
      percentage = cvi_cadastral_plant.area / context.new_cvi_land_parcel.declared_area
      context.new_cvi_land_parcel.cvi_cadastral_plant_cvi_land_parcels.create!(cvi_cadastral_plant: cvi_cadastral_plant, percentage: percentage )
    end
  end

  def set_main_rootstock
    rootstocks_percentages = context.new_cvi_land_parcel.cvi_cadastral_plant_cvi_land_parcels.map do |ccp_clp|
      { rootstock_id: ccp_clp.cvi_cadastral_plant.rootstock_id, percentage: ccp_clp.percentage }
    end.group_by{ |x| x[:rootstock_id]}.map do |key,value| 
      { rootstock_id: key, percentage: value.inject(0) {|sum,hash| sum + hash[:percentage]}}
    end
    context.new_cvi_land_parcel.update_attribute('rootstock_id', rootstocks_percentages.max { |a, b| a[:percentage] <=> b[:percentage]}[:rootstock_id])
  end

  def set_main_campaign
    rootstocks_percentages = context.new_cvi_land_parcel.cvi_cadastral_plant_cvi_land_parcels.map do |ccp_clp|
      { campaign: ccp_clp.cvi_cadastral_plant.planting_campaign, percentage: ccp_clp.percentage }
    end.group_by{ |x| x[:campaign]}.map do |key,value| 
      { campaign: key, percentage: value.inject(0) {|sum,hash| sum + hash[:percentage]}}
    end
    context.new_cvi_land_parcel.update_attribute( 'planting_campaign', rootstocks_percentages.max { |a, b| a[:percentage] <=> b[:percentage]}[:campaign])
  end

  def create_associated_locations
    new_locations = context.cvi_land_parcels.flat_map(&:locations).uniq { |r| [r.registered_postal_zone_id, r.locality] }.map(&:dup)
    context.new_cvi_land_parcel.locations.create!(new_locations.map(&:attributes))
  end

  def destroy_grouped_records
    context.cvi_land_parcels.each(&:destroy)
  end
end