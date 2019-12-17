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
end
