require 'test_helper'

class GenerateCviCultivableZonesTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  setup do
    @cvi_statement = create(:cvi_statement, :with_cvi_cadastral_plants)
  end

  attr_reader :cvi_statement

  test 'GenerateCviCultivableZones.call create the right number of cvi_cultivable_zone' do
    assert_difference 'CviCultivableZone.count', 3 do
      GenerateCviCultivableZones.call(cvi_statement: cvi_statement)
    end
  end

  test "GenerateCviCultivableZones.call fail if one cvi cadastral plant don't have cadastral land parcel" do
    cvi_statement.cvi_cadastral_plants.first.update_attribute('land_parcel_id', nil)
    result = GenerateCviCultivableZones.call(cvi_statement: cvi_statement)
    assert result.failure?
  end
end
