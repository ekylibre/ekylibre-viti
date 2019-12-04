require 'test_helper'

class CviCultivableZoneTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  should 'be creatable' do
    resource = create(:cvi_cultivable_zone)
    first_resource = CviCultivableZone.last
    assert_equal resource, first_resource
  end

  context 'Aggregations' do
    should 'respond to calculated_area  with measure object' do
      resource = create(:cvi_cultivable_zone)
      assert_equal 'Measure', resource.calculated_area.class.name
    end
    should 'respond to declared_area  with measure object' do
      resource = create(:cvi_cultivable_zone)
      assert_equal 'Measure', resource.declared_area.class.name
    end
  end

  context 'validations' do
    should validate_presence_of(:name)
  end

  context 'associations' do
    should belong_to(:cvi_statement)
    should have_many(:cvi_cadastral_plants)
    should have_many(:cvi_land_parcels)
    should have_many(:locations)
  end

  should enumerize(:land_parcels_status).in(:not_created,:created).with_predicates(true)

  should "set formatted_declared_area when created" do
    resource = create(:cvi_cultivable_zone,declared_area_value: 1.10, declared_area_unit: :hectare)
    assert_equal "01ha 10a 00ca", resource.reload.formatted_declared_area 
  end

  should "udpate formatted_declared_area when declared_area is updated " do
    resource = create(:cvi_cultivable_zone)
    resource.update(declared_area_value: 1.10, declared_area_unit: :hectare)
    assert_equal "01ha 10a 00ca" , resource.reload.formatted_declared_area
  end

  should "set formatted_calculated_area when created" do
    resource = create(:cvi_cultivable_zone,calculated_area_value: 1.10, calculated_area_unit: :hectare)
    assert_equal "01ha 10a 00ca", resource.reload.formatted_calculated_area 
  end

  should "udpate formatted_calculated_area when calculated_area is updated " do
    resource = create(:cvi_cultivable_zone)
    resource.update(calculated_area_value: 1.10, calculated_area_unit: :hectare)
    assert_equal "01ha 10a 00ca" , resource.reload.formatted_calculated_area
  end
end
