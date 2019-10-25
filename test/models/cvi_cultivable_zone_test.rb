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
  end

  context 'validations' do
    should validate_presence_of(:name)
  end

  context 'associations' do
    should belong_to(:cvi_statement)
    should have_many(:cvi_cadastral_plants)
  end

  should enumerize(:land_parcels_status).in(:not_created,:created).with_predicates(true)

  should 'respond to communes with all communes of associated model cvi cadastral_plants' do
    resource = create(:cvi_cultivable_zone, :with_cvi_cadastral_plants)
    assert_equal resource.cvi_cadastral_plants.count, resource.communes.count
  end

  should 'respond to cadastral_references with all communes of associated model cvi cadastral_plants' do
    resource = create(:cvi_cultivable_zone, :with_cvi_cadastral_plants)
    assert_equal resource.cvi_cadastral_plants.count, resource.cadastral_references.count
  end

  should 'respond to declared_area with all communes of associated model cvi cadastral_plants' do
    resource = create(:cvi_cultivable_zone, :with_cvi_cadastral_plants)
    area_sum  = resource.cvi_cadastral_plants.collect(&:area).sum
    assert_equal area_sum, resource.declared_area
  end
end
