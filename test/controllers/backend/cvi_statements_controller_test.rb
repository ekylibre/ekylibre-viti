require 'test_helper'
module Backend
  class CviStatementsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[show index edit new update destroy list_cvi_cadastral_plants list_cvi_cadastral_plants_map list update_campaign ]

    context '#update_campaign' do
      should 'Update resource with campaign' do
        @cvi_statement = create(:cvi_statement)
        @campaign = create(:campaign)
        patch :update_campaign, id: @cvi_statement.id, campaign: '2031'
        assert_equal @campaign, @cvi_statement.reload.campaign
      end
    end
    
  end
end
