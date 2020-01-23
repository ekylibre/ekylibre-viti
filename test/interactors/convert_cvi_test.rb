require 'test_helper'

class ConvertCviTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  describe('ConvertCvi.call') do
    let(:cvi_statement) { create(:cvi_statement, :with_cvi_cultivable_zones_ready_to_convert) }

    it 'creates all activities for the cvi_statement campaign' do
      ConvertCvi.call(cvi_statement: cvi_statement)
      activity_count = cvi_statement.cvi_land_parcels.collect(&:activity).uniq.length
      assert_equal activity_count, 
                    (cvi_statement.campaign.activities.collect(&:id) &
                      cvi_statement.cvi_land_parcels.collect(&:activity).collect(&:id)).length
    end
      
    it 'creates same number of cultivable_zones as existing cvi_cultivable_zones' do
      assert_difference 'CultivableZone.count', cvi_statement.cvi_cultivable_zones.count do
        ConvertCvi.call(cvi_statement: cvi_statement)
      end
    end

    it 'set cultivable_zone attributes correctly' do
      ConvertCvi.call(cvi_statement: cvi_statement)
      cvi_cultivable_zone = cvi_statement.cvi_cultivable_zones.first
      cultivable_zone = CultivableZone.find_by(name: cvi_cultivable_zone.name)
      assert_equal cvi_cultivable_zone.shape, cultivable_zone.shape
    end

    it 'creates same number of land_parcels as existing cvi_land_parcels' do
      assert_difference 'LandParcel.count', cvi_statement.cvi_land_parcels.count do
        ConvertCvi.call(cvi_statement: cvi_statement)
      end
    end

    it 'set land_parcels attributes correctly' do
      ConvertCvi.call(cvi_statement: cvi_statement)
      cvi_land_parcel = cvi_statement.cvi_land_parcels.first
      land_parcel = LandParcel.find_by(name: cvi_land_parcel.name)
      assert_equal cvi_land_parcel.shape, land_parcel.initial_shape
    end

    it 'generates same number of activity_production as existing cvi_land_parcels' do
      assert_difference 'ActivityProduction.count', cvi_statement.cvi_land_parcels.count do
        ConvertCvi.call(cvi_statement: cvi_statement)
      end
    end
  end
end