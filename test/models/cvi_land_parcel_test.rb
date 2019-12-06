require 'test_helper'

class CviLandParcelTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  should 'be creatable' do
    cvi_land_parcel = create(:cvi_land_parcel)
    first_cvi_land_parcel = CviLandParcel.last
    assert_equal cvi_land_parcel, first_cvi_land_parcel
  end

  context 'Aggregations' do
    should 'respond to calculated_area  with measure object' do
      resource = create(:cvi_land_parcel)
      assert_equal 'Measure', resource.calculated_area.class.name
    end
    should 'respond to declared_area  with measure object' do
      resource = create(:cvi_land_parcel)
      assert_equal 'Measure', resource.declared_area.class.name
    end
    should 'respond to inter_row_distance  with measure object' do
      resource = create(:cvi_land_parcel)
      assert_equal 'Measure', resource.inter_row_distance.class.name
    end
    should 'respond to inter_vine_plant_distance with measure object' do
      resource = create(:cvi_land_parcel)
      assert_equal 'Measure', resource.inter_vine_plant_distance.class.name
    end
  end

  context 'validations' do
    should validate_presence_of(:name)
  end

  context 'associations' do
    should belong_to(:cvi_cultivable_zone)
    should belong_to(:designation_of_origin).with_foreign_key('designation_of_origin_id')
    should belong_to(:vine_variety).with_foreign_key('vine_variety_id')
    should belong_to(:rootstock).with_foreign_key('rootstock_id')
    should have_many(:locations)
  end

  should enumerize(:state).in(:planted, :removed_with_authorization).with_predicates(true)

  describe '#updated?' do
    it 'return true if resource have already been updated' do
      resource = create(:cvi_land_parcel)
      resource.update(attributes_for(:cvi_land_parcel))
      assert(resource.reload.updated?)
    end
  end

  describe 'callbacks' do
    it 'calculated_area is updated when shape change' do
      resource = create(:cvi_land_parcel)
      shape = FFaker::Shape.multipolygon
      resource.update(shape: shape)
      assert_equal Measure.new(shape.area, :square_meter).convert(:hectare).value.round(5), resource.reload.calculated_area_value
    end
  end
end
