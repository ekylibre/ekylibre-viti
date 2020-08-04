require 'test_helper'

class GenerateCviCultivableZonesTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  describe('GenerateCviCultivableZones.call') do
    let(:cvi_statement) { create(:cvi_statement, :with_cvi_cadastral_plants) }
      
    it 'create cvi_cultivable_zone' do
      assert_difference 'CviCultivableZone.count', 3 do
        GenerateCviCultivableZones.call(cvi_statement: cvi_statement)
      end
    end
  end
end