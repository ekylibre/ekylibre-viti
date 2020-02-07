require 'test_helper'
module Backend
  class CviCultivableZonesControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[show update delete_modal generate_cvi_land_parcels edit_cvi_land_parcels confirm_cvi_land_parcels index]

    describe('#delete_modal') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }

      it 'gets delete_modal' do
        xhr :get, :delete_modal, id: cvi_cultivable_zone.id, format: :js
        assert_response :success
      end
    end

    describe('#update') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }
      let(:params) { attributes_for(:cvi_cultivable_zone,name: 'new_name')}

      it 'updates record' do
        xhr :put, :update, id: cvi_cultivable_zone.id, cvi_cultivable_zone: params
        assert_equal 'new_name', cvi_cultivable_zone.reload.name
        assert_equal Charta.new_geometry(params[:shape]), cvi_cultivable_zone.reload.shape
      end

      it 'responds with success' do
        xhr :put, :update, id: cvi_cultivable_zone.id, cvi_cultivable_zone: params
        assert_response :success
      end
    end

    describe('#generate_cvi_land_parcels') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, :with_cvi_cadastral_plants) }

      it 'redirects' do
        get :generate_cvi_land_parcels, id: cvi_cultivable_zone.id
        assert_response :redirect
      end
    end

    describe('#confirm_cvi_land_parcels') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, :with_cvi_land_parcels, land_parcels_status: :not_created) }

      it 'sets cvi_land_parcels_status to created' do
        get :confirm_cvi_land_parcels, id: cvi_cultivable_zone.id
        assert_equal 'created', cvi_cultivable_zone.reload.land_parcels_status
      end

      it 'updates cvi_cultivable_zone calculated_surface with the sum of associated cvi_land_parcels areas' do
        get :confirm_cvi_land_parcels, id: cvi_cultivable_zone.id
        assert_in_epsilon cvi_cultivable_zone.cvi_land_parcels.collect { |e| e.shape.area }.sum / 10_000, cvi_cultivable_zone.reload.calculated_area_value.to_f, epsilon = 0.001
      end
    end
  end
end