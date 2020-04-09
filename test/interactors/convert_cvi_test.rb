require 'test_helper'

class ConvertCviTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  describe('ConvertCvi.call') do
    let(:cvi_statement) { create(:cvi_statement, :with_one_cvi_cultivable_zone_ready_to_convert) }
    let(:cvi_land_parcel) { cvi_statement.cvi_land_parcels.first }

    it 'create a new activity production with correct attributes' do 
      ConvertCvi.call(cvi_statement_id: cvi_statement.id)
      activity = cvi_land_parcel.activity
      created_activity_production = ActivityProduction.last
      assert_equal 'headland_cultivation' , created_activity_production.support_nature
      assert_equal 'fruit' , created_activity_production.usage
      assert_equal Campaign.of(cvi_land_parcel.planting_campaign) , created_activity_production.planting_campaign
      assert_equal 'headland_cultivation' , created_activity_production.support_nature
      assert_equal Hash['cvi_land_parcel_id', cvi_land_parcel.id ] , created_activity_production.providers
      assert_equal Date.new(cvi_land_parcel.planting_campaign.to_i + activity.start_state_of_production.keys.first.to_i, activity.production_started_on.month, activity.production_started_on.day),
                   created_activity_production.started_on
      assert_equal Date.new(cvi_land_parcel.planting_campaign.to_i + activity.life_duration.to_i, activity.production_stopped_on.month, activity.production_stopped_on.day), 
                   created_activity_production.stopped_on
    end

    describe 'activities are not setted' do
      it 'conversion fail' do
        cvi_land_parcel.update(activity_id: nil)
        result = ConvertCvi.call(cvi_statement_id: cvi_statement.id)
        refute result.success?
      end
    end

    describe 'a production with the same shape already exist' do
      it "use existing activity_production" do
        activity_production = create(:activity_production, activity: cvi_land_parcel.activity)
        cvi_land_parcel.update(shape: Charta.new_geometry("SRID=4326;MULTIPOLYGON (((-0.9428286552429199 43.77818419848836, -0.9408894181251525 43.777330143623416, -0.9400096535682678 43.77828102933575, -0.9415814280509949 43.778892996664055, -0.9428286552429199 43.77818419848836)))").to_rgeo)
        assert_difference 'ActivityProduction.count', 0 do
          ConvertCvi.call(cvi_statement_id: cvi_statement.id)
        end
        
      end
    end
    
    describe 'a production with the same provider already exist' do
      it "use existing activity_production" do
        activity_production = create(:activity_production, activity: cvi_land_parcel.activity, providers: { cvi_land_parcel_id: cvi_land_parcel.id } )
        assert_difference 'ActivityProduction.count', 0 do
          ConvertCvi.call(cvi_statement_id: cvi_statement.id)
        end
      end
    end 
  end
end