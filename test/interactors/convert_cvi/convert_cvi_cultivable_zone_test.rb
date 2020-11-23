require 'test_helper'

module ConvertCvi
  class ConvertCviCultivableZoneTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
    describe "#ConvertCviCultivableZone" do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, shape: 'POLYGON ((-0.2532838 45.7793677956054, -0.252766 45.7806597956059, -0.25263 45.7806092956059, -0.2531423 45.7793327956054, -0.2532838 45.7793677956054))') }

      it 'create new cultivable zone with correct attributes' do
        returned_cultivable_zone = ConvertCviCultivableZone.call(cvi_cultivable_zone)
        assert_equal cvi_cultivable_zone.name, returned_cultivable_zone.name
        assert_equal "Convert from CVI ID : #{cvi_cultivable_zone.cvi_statement_id}", returned_cultivable_zone.description
        assert_equal cvi_cultivable_zone.shape.convert_to(:multi_polygon), returned_cultivable_zone.shape
      end

      describe "there is a cultivable_zone with the same shape as cvi_cultivable_zone" do
        it 'return the existing cultivable zone' do
          cultivable_zone = create(:cultivable_zone, shape: 'POLYGON ((-0.2532838 45.7793677956054, -0.252766 45.7806597956059, -0.25263 45.7806092956059, -0.2531423 45.7793327956054, -0.2532838 45.7793677956054))')
          returned_cultivable_zone = ConvertCviCultivableZone.call(cvi_cultivable_zone)
          assert_equal cultivable_zone.id, returned_cultivable_zone.id
        end
      end

      describe "there is a cultivable_zone with the same name as cvi_cultivable_zone" do
        it 'return the existing cultivable zone' do
          cultivable_zone = create(:cultivable_zone, name: cvi_cultivable_zone.name)
          returned_cultivable_zone = ConvertCviCultivableZone.call(cvi_cultivable_zone)
          assert_equal cultivable_zone.id, returned_cultivable_zone.id
        end
      end
    end
  end
end
