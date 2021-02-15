require 'test_helper'

class GenerateCviCultivableZonesTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  test 'GenerateCviCultivableZones.call create cvi_cultivable_zone' do
    cvi_statement = create(:cvi_statement, :with_cvi_cadastral_plants)
    assert_difference 'CviCultivableZone.count', 3 do
      GenerateCviCultivableZones.call(cvi_statement: cvi_statement)
    end
  end
end
