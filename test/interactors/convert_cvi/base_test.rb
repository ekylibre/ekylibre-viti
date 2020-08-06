require 'test_helper'

module ConvertCvi
  class BaseTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
    setup do
      @cvi_statement = create(:cvi_statement, :with_one_cvi_cultivable_zone_ready_to_convert)
      @cvi_land_parcel = @cvi_statement.cvi_land_parcels.first
    end

    test 'conversion fails if activity is not setted' do
      @cvi_land_parcel.update_attribute('activity_id', nil)
      result = ConvertCvi::Base.call(cvi_statement_id: @cvi_statement.id)
      assert_not result.success?
    end

    test 'conversion succeed' do
      result = ConvertCvi::Base.call(cvi_statement_id: @cvi_statement.id)
      assert result.success?
    end
  end
end
