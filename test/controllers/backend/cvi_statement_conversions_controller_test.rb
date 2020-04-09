require 'test_helper'

module Backend
  class CviStatementConversionsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions class_name: 'CviStatement', except: %i[show create reset convert_modal]

    describe('#convert_modal') do
      let(:cvi_statement) { create(:cvi_statement,) }

      it 'gets convert_modal' do
        xhr :get, :convert_modal, id: cvi_statement.id, format: :js
        assert_response :success
      end
    end

    describe '#show' do
      let(:invalid_cvi_statement) { create(:cvi_statement) }
      let(:valid_cvi_statement) { create(:cvi_statement, :with_cvi_cultivable_zone) }

      it 'raise error if conversion doesn\'t exsite' do
        assert_raises(ActiveRecord::RecordNotFound) do 
          get :show, id: invalid_cvi_statement.id
        end
      end

      it 'get show' do
        get :show, id: valid_cvi_statement, locale: @locale 
        assert_response :success
        assert_not_nil assigns(:cvi_statement)
      end
    end

    describe '#create' do
      let(:cvi_statement) { create(:cvi_statement, :with_cvi_cadastral_plants) }
      let(:campaign) { create(:campaign) }

      it 'update cvi_statement with campaign' do
        post :create, id: cvi_statement.id, campaign: campaign.name
        assert_equal campaign, cvi_statement.reload.campaign
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