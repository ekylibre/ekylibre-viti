require 'test_helper'

module ConvertCvi
  class ConvertCviCultivableZoneTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
    setup do
      @cvi_cultivable_zone = create(:cvi_cultivable_zone, shape: 'POLYGON ((-0.2532838 45.7793677956054, -0.252766 45.7806597956059, -0.25263 45.7806092956059, -0.2531423 45.7793327956054, -0.2532838 45.7793677956054))')
    end

    attr_reader :cvi_cultivable_zone

    test '#ConvertCviCultivableZone create new cultivable zone with correct attributes' do
      returned_cultivable_zone = ConvertCviCultivableZone.call(cvi_cultivable_zone)
      assert_equal cvi_cultivable_zone.name, returned_cultivable_zone.name
      assert_equal "ZC##{CultivableZone.count}_CVI", returned_cultivable_zone.work_number
      assert_equal cvi_cultivable_zone.shape.convert_to(:multi_polygon), returned_cultivable_zone.shape
    end

    test "#ConvertCviCultivableZone when there is a cultivable_zone with the same shape as cvi_cultivable_zone" do
      cultivable_zone = create(:cultivable_zone, shape: 'POLYGON ((-0.2532838 45.7793677956054, -0.252766 45.7806597956059, -0.25263 45.7806092956059, -0.2531423 45.7793327956054, -0.2532838 45.7793677956054))')
      returned_cultivable_zone = ConvertCviCultivableZone.call(cvi_cultivable_zone)
      assert_equal cultivable_zone.id, returned_cultivable_zone.id, "It return the existing cultivable zone"
    end

    test "#ConvertCviCultivableZone when there is a cultivable_zone with the same name as cvi_cultivable_zone" do
      create(:cultivable_zone, name: cvi_cultivable_zone.name)
      cultivable_zone = create(:cultivable_zone, name: "#{cvi_cultivable_zone.name} (1)")
      returned_cultivable_zone = ConvertCviCultivableZone.call(cvi_cultivable_zone)
      assert_not_equal cultivable_zone.id, returned_cultivable_zone.id, 'return a new cultivable with different id'
      assert_equal "#{cvi_cultivable_zone.name} (2)", returned_cultivable_zone.name, 'return a new cultivable zone with correct name'
    end
  end
end
