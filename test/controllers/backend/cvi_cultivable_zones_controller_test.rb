require 'test_helper'
require_relative '../../test_helper'

module Backend
  class CviCultivableZonesControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[show update delete_modal generate_cvi_land_parcels edit_cvi_land_parcels confirm_cvi_land_parcels index group reset reset_modal]

    describe('#delete_modal') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }

      it 'gets delete_modal' do
        xhr :get, :delete_modal, params: { id: cvi_cultivable_zone.id, format: :js }
        assert_response :success
      end
    end

    describe('#reset_modal') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }

      it 'gets reset_modal' do
        xhr :get, :reset_modal, params: { id: cvi_cultivable_zone.id, format: :js }
        assert_response :success
      end
    end

    describe('#update') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }
      let(:params) { attributes_for(:cvi_cultivable_zone, name: 'new_name') }

      it 'updates record' do
        xhr :put, :update, params: { id: cvi_cultivable_zone.id, cvi_cultivable_zone: params }
        assert_equal 'new_name', cvi_cultivable_zone.reload.name
        assert_equal Charta.new_geometry(params[:shape]), cvi_cultivable_zone.reload.shape
      end

      it 'responds with success' do
        xhr :put, :update, params: { id: cvi_cultivable_zone.id, cvi_cultivable_zone: params }
        assert_response :success
      end
    end

    describe('#generate_cvi_land_parcels') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, :with_cvi_cadastral_plants) }

      it 'redirects' do
        get :generate_cvi_land_parcels, params: { id: cvi_cultivable_zone.id }
        assert_response :redirect
      end
    end

    describe('#confirm_cvi_land_parcels') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, :with_cvi_land_parcels, land_parcels_status: :completed) }

      it 'sets cvi_land_parcels_status to completed' do
        get :confirm_cvi_land_parcels, params: { id: cvi_cultivable_zone.id }
        assert_equal 'completed', cvi_cultivable_zone.reload.land_parcels_status
      end
    end

    describe('#reset') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, :with_cvi_cadastral_plants) }

      it 'sets cvi_land_parcels_status to started' do
        get :reset, params: { id: cvi_cultivable_zone.id }
        assert_equal 'started', cvi_cultivable_zone.reload.land_parcels_status
      end

      it 'updates cvi_cultivable_zone calculated_surface with the sum of associated cvi_cadastral_plant' do
        get :reset, params: { id: cvi_cultivable_zone.id }
        assert_in_delta cvi_cultivable_zone.cvi_cadastral_plants.collect { |e| e.shape.area }.sum / 10_000, cvi_cultivable_zone.reload.calculated_area_value.to_f, epsilon = 0.0001
      end
    end

    describe('#edit_cvi_land_parcels') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, :with_cvi_cadastral_plants) }

      it 'sets cvi_land_parcels_status to started' do
        get :edit_cvi_land_parcels, params: { id: cvi_cultivable_zone.id }
        assert_equal 'started', cvi_cultivable_zone.reload.land_parcels_status
      end
    end
  end
end
