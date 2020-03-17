require 'test_helper'

class CviLandParcelTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  it 'is creatable' do
    cvi_land_parcel = create(:cvi_land_parcel)
    first_cvi_land_parcel = CviLandParcel.last
    assert_equal cvi_land_parcel, first_cvi_land_parcel
  end

  it 'responds to calculated_area with measure object' do
    resource = create(:cvi_land_parcel)
    assert_equal 'Measure', resource.calculated_area.class.name
  end
  it 'responds to declared_area with measure object' do
    resource = create(:cvi_land_parcel)
    assert_equal 'Measure', resource.declared_area.class.name
  end
  it 'responds to inter_row_distance with measure object' do
    resource = create(:cvi_land_parcel)
    assert_equal 'Measure', resource.inter_row_distance.class.name
  end
  it 'responds to inter_vine_plant_distance with measure object' do
    resource = create(:cvi_land_parcel)
    assert_equal 'Measure', resource.inter_vine_plant_distance.class.name
  end

  should validate_presence_of(:name)
  should validate_presence_of(:inter_row_distance_value)
  should validate_presence_of(:inter_vine_plant_distance_value)
  should validate_presence_of(:vine_variety_id)

  should belong_to(:cvi_cultivable_zone)
  should belong_to(:designation_of_origin).with_foreign_key('designation_of_origin_id')
  should belong_to(:vine_variety).with_foreign_key('vine_variety_id')
  should have_many(:land_parcel_rootstocks)
  should have_many(:locations)
  should have_many(:cvi_cadastral_plant_cvi_land_parcels)

  should enumerize(:state).in(:planted, :removed_with_authorization).with_predicates(true)

  it 'responds to updated? with true, if it has already been updated' do
    resource = create(:cvi_land_parcel)
    resource.update(attributes_for(:cvi_land_parcel))
    assert(resource.reload.updated?)
  end

  it 'has calculated_area setted when shape change' do
    resource = create(:cvi_land_parcel)
    assert_in_delta Measure.new(resource.reload.shape.area, :square_meter).convert(:hectare).value, resource.reload.calculated_area_value, delta = 0.00001
    shape = FFaker::Shape.multipolygon
    resource.update(shape: shape)
    assert_in_delta Measure.new(shape.area, :square_meter).convert(:hectare).value, resource.reload.calculated_area_value, delta = 0.00001
  end
end
