require 'test_helper'

module Backend
  class CviStatementConversionsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions class_name: 'CviStatement', only: %i[show list_cvi_cultivable_zones]

    describe '#create' do
      let(:cvi_statement) { create(:cvi_statement, :with_cvi_cadastral_plants) }
      let(:campaign) { create(:campaign) }

      it 'update cvi_statement with campaign' do
        post :create, id: cvi_statement.id, campaign: campaign.name
        assert_equal campaign, cvi_statement.reload.campaign
      end

      it 'create cvi_cultivable_zone' do
        post :create, id: cvi_statement.id, campaign: campaign.name
        assert_equal 3, CviCultivableZone.count
      end

      it 'redirect to #show' do 
        post :create, id: cvi_statement.id, campaign: campaign.name
        assert_redirected_to backend_cvi_statement_conversion_path(cvi_statement)
      end
    end

    describe '#reset' do
      let(:cvi_statement) { create(:cvi_statement, :with_cvi_cultivable_zone) }

      it 'delete cvi_cultivabls zones and recreate it' do
        get :reset, id: cvi_statement.id
        assert_not_equal CviCultivableZone.last, cvi_statement.cvi_cultivable_zones.first
      end

      it 'redirect to #show' do
        post :reset, id: cvi_statement.id
        assert_redirected_to backend_cvi_statement_conversion_path(cvi_statement)
      end
    end
  end
end