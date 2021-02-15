require 'test_helper'
require_relative '../../test_helper'

module Backend
  class CviCultivableZonesControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[show update delete_modal generate_cvi_land_parcels edit_cvi_land_parcels confirm_cvi_land_parcels index group reset reset_modal]

    setup do
      @cvi_cultivable_zone = create(:cvi_cultivable_zone)
      @params_for_update = attributes_for(:cvi_cultivable_zone, name: 'new_name')
      @cvi_cultivable_zone_with_cp = create(:cvi_cultivable_zone, :with_cvi_cadastral_plants)
    end

    attr_reader :cvi_cultivable_zone, :params_for_update, :cvi_cultivable_zone_with_cp

    test "get delete_modal respond with success" do
      get :delete_modal, params: { id: cvi_cultivable_zone.id, format: :js }, xhr: true
      assert_response :success
    end

    test "get reset_modal respond with success" do
      get :reset_modal, params: { id: cvi_cultivable_zone.id, format: :js }, xhr: true
      assert_response :success
    end

    test '#update' do
      put :update, params: { id: cvi_cultivable_zone.id, cvi_cultivable_zone: params_for_update }, xhr: true
      assert_equal 'new_name', cvi_cultivable_zone.reload.name, 'update name'
      assert_equal Charta.new_geometry(params_for_update[:shape]), cvi_cultivable_zone.reload.shape, 'updates shape'
      assert_response :success, 'responds with success'
    end

    test '#generate_cvi_land_parcels redirects' do
      get :generate_cvi_land_parcels, params: { id: cvi_cultivable_zone_with_cp.id }
      assert_response :redirect
    end

    test '#confirm_cvi_land_parcels sets cvi_land_parcels_status to completed' do
      cvi_cultivable_zone_with_clp = create(:cvi_cultivable_zone, :with_cvi_land_parcels, land_parcels_status: :completed)
      get :confirm_cvi_land_parcels, params: { id: cvi_cultivable_zone_with_clp.id }
      assert_equal 'completed', cvi_cultivable_zone_with_clp.reload.land_parcels_status
    end

    test 'test#reset' do
      get :reset, params: { id: cvi_cultivable_zone_with_cp.id }
      assert_equal 'started', cvi_cultivable_zone_with_cp.reload.land_parcels_status, 'sets cvi_land_parcels_status to started'
      assert_in_delta cvi_cultivable_zone_with_cp.cvi_cadastral_plants.collect { |e| e.shape.area }.sum / 10_000, cvi_cultivable_zone_with_cp.reload.calculated_area_value.to_f, 0.0001, 'updates cvi_cultivable_zone calculated_surface with the sum of associated cvi_cadastral_plant'
    end

    test  '#edit_cvi_land_parcels sets cvi_land_parcels_status to started' do
      get :edit_cvi_land_parcels, params: { id: cvi_cultivable_zone_with_cp.id }
      assert_equal 'started', cvi_cultivable_zone_with_cp.reload.land_parcels_status
    end
  end
end
