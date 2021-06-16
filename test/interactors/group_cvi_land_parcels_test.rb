require 'test_helper'

class GroupCviLandParcelsTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  ATTRIBUTES = %i[designation_of_origin_id vine_variety_id inter_vine_plant_distance_value inter_row_distance_value state activity_id].freeze

  test('#call if cvi_land_parcels are not groupable') do
    cvi_land_parcels = create_list(:cvi_land_parcel, 2, :not_groupable, :new_splitted)
    result = GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
    assert_equal cvi_land_parcels, CviLandParcel.find(cvi_land_parcels.collect(&:id)), "doesn't create or delete cvi_land_parcel"
    assert_equal :can_not_group_cvi_land_parcels, result.error, "return an error message"
    assert_equal ATTRIBUTES, result.attributes, 'has different attributes'
  end

  test('#call if cvi_land_parcels are not groupable because of shape') do
    cvi_land_parcels = create_list(:cvi_land_parcel, 2, :groupable)
    result = GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
    assert_equal cvi_land_parcels, CviLandParcel.find(cvi_land_parcels.collect(&:id)), "doesn't create or delete cvi_land_parcel"
    assert result.error.include?('intersection'), "return an error message"
  end

  test('#call if cvi_land_parcels are groupable') do
    cvi_land_parcels = create_list(:cvi_land_parcel, 2, :groupable, :new_splitted)

    GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)

    name = cvi_land_parcels.map(&:name).sort.join(', ')
    cvi_land_parcel = CviLandParcel.last
    assert_equal cvi_land_parcels.map(&:declared_area).sum, cvi_land_parcel.declared_area, 'Create à new record from records with correct declared area'
    assert_in_delta cvi_land_parcels.map(&:calculated_area_value).sum, cvi_land_parcel.calculated_area.value, 0.001, 'Create à new record from records with correct calculated area'
    assert_equal name, cvi_land_parcel.name, 'Create à new record from records with correct name'

    total_area = cvi_land_parcels.sum(&:declared_area)
    area_rootstock1 = cvi_land_parcels.first.cvi_cadastral_plants.first.area
    area_rootstock2 = cvi_land_parcels.second.cvi_cadastral_plants.first.area
    percentage1 = area_rootstock1 / total_area
    percentage2 = area_rootstock2 / total_area
    assert_in_delta(percentage1, cvi_land_parcel.cvi_cadastral_plant_cvi_land_parcels.first.percentage, 0.01, 'It set the percentage')
    assert_in_delta(percentage2, cvi_land_parcel.cvi_cadastral_plant_cvi_land_parcels.second.percentage, 0.01, 'It set the percentage')

    main_cvi_cadastral_plant = cvi_land_parcel.cvi_cadastral_plants.order(:area_value).last
    assert_equal main_cvi_cadastral_plant.planting_campaign, cvi_land_parcel.planting_campaign, 'It sets the main campaign'
    assert_equal main_cvi_cadastral_plant.rootstock_id, cvi_land_parcel.rootstock_id, 'It sets the main rootstock'

    assert_raise ActiveRecord::RecordNotFound, 'It destroy grouped cvi_land_parcels' do
      CviLandParcel.find(cvi_land_parcels.map(&:id))
    end
  end
end
