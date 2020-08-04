require 'test_helper'

module Backend
  class CviStatementConversionsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions class_name: 'CviStatement', except: %i[show create reset convert_modal convert]

    def setup
      @cvi_statement = create(:cvi_statement)
      @valid_cvi_statement = create(:cvi_statement, :with_cvi_cultivable_zone)
      @campaign = create(:campaign)
      @cvi_statement_ready_to_convert = create(:cvi_statement, :with_one_cvi_cultivable_zone_ready_to_convert)
    end

    # test '#convert_modal respond with success' do
    #   xhr :get, :convert_modal, id: @cvi_statement.id, format: :js
    #   assert_response :success
    # end

    # test '#show raise error if conversion doesn\'t exist' do
    #   assert_raises(ActiveRecord::RecordNotFound) do 
    #     get :show, id: @cvi_statement.id
    #   end
    # end

    # test '#show respond with success' do
    #   get :show, id: @valid_cvi_statement, locale: @locale 
    #   assert_response :success
    #   assert_not_nil assigns(:cvi_statement)
    # end

    # test '#create update cvi_statement with campaign' do
    #   post :create, id: @cvi_statement.id, campaign: @campaign.name
    #   assert_equal @campaign, @cvi_statement.reload.campaign
    # end

    # test '#create redirect to #show' do 
    #   post :create, id: @cvi_statement.id, campaign: @campaign.name
    #   assert_redirected_to backend_cvi_statement_conversion_path(@cvi_statement)
    # end

    # test '#reset delete cvi_cultivabls zones and recreate it' do
    #   get :reset, id:  @valid_cvi_statement.id
    #   assert_not_equal CviCultivableZone.last, @valid_cvi_statement.cvi_cultivable_zones.first
    # end

    # test '#reset redirect to #show' do
    #   post :reset, id: @valid_cvi_statement.id
    #   assert_redirected_to backend_cvi_statement_conversion_path(@valid_cvi_statement)
    # end

    test '#convert redirect to cvi_statements index if it succeed' do
      post :convert, id: @cvi_statement_ready_to_convert.id
      assert_redirected_to backend_cvi_statements_path
    end

    # test '#convert redirect to cvi_statements_conversion show if it failed' do
    #   @cvi_statement_ready_to_convert.cvi_land_parcels.first.update_attribute('activity_id', nil)
    #   post :convert, id: @cvi_statement_ready_to_convert.id
    #   assert_redirected_to backend_cvi_statement_conversion_path(@cvi_statement_ready_to_convert.id)
    # end
  end
end
