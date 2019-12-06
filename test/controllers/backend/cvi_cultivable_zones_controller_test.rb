require 'test_helper'
module Backend
  class CviCultivableZonesControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[update delete_modal index edit edit_cvi_land_parcels generate_cvi_land_parcels show confirm_cvi_land_parcels]

    describe('#delete_modal') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }

      it 'get delete_modal' do
        xhr :get, :delete_modal, id: cvi_cultivable_zone.id, format: :js
        assert_response :success
      end
    end

    describe('#update') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }

      it 'updates record' do
        xhr :put, :update, id: cvi_cultivable_zone.id, cvi_cultivable_zone: { name: 'new_name' }
        assert_equal 'new_name', cvi_cultivable_zone.reload.name
      end

      it 'responds with success' do
        xhr :put, :update, id: cvi_cultivable_zone.id, cvi_cultivable_zone: { name: 'new_name' }
        assert_response :success
      end
    end

    describe('#generate_cvi_land_parcels') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, :with_cvi_cadastral_plants) }
      ATTRIBUTES = %w[commune locality planting_campaign designation_of_origin_id vine_variety_id inter_vine_plant_distance_value inter_row_distance_value inter_vine_plant_distance_unit inter_row_distance_unit state rootstock_id].freeze

      it 'redirect' do
        get :generate_cvi_land_parcels, id: cvi_cultivable_zone.id
        assert_response :redirect
      end

      it 'generate the same number of cvi_land_parcel as existing cvi_cadastral_plants' do
        assert_difference 'CviLandParcel.count', cvi_cultivable_zone.cvi_cadastral_plants.count do
          get :generate_cvi_land_parcels, id: cvi_cultivable_zone.id
        end
      end

      it 'attributes value are correctly setted ' do
        get :generate_cvi_land_parcels, id: cvi_cultivable_zone.id
        assert_equal cvi_cultivable_zone.cvi_cadastral_plants.collect(&:cadastral_reference).sort, cvi_cultivable_zone.cvi_land_parcels.collect(&:name).sort
        cvi_cadastral_plant = CviCadastralPlant.last
        cvi_land_parcel = CviLandParcel.find_by(name: cvi_cadastral_plant.cadastral_reference)
        assert_equal cvi_cadastral_plant.shape, cvi_land_parcel.shape
      end
    end

    describe('#confirm_cvi_land_parcels') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, :with_cvi_land_parcels, land_parcels_status: :not_created) }

      it 'set cvi_land_parcels_status to created' do
        get :confirm_cvi_land_parcels, id: cvi_cultivable_zone.id
        assert_equal 'created', cvi_cultivable_zone.reload.land_parcels_status
      end

      it 'update cvi_cultivable_zone calculated_surface with the sum of associated cvi_land_parcels areas ' do
        get :confirm_cvi_land_parcels, id: cvi_cultivable_zone.id
        assert_in_epsilon cvi_cultivable_zone.cvi_land_parcels.collect { |e| e.shape.area }.sum / 10_000, cvi_cultivable_zone.reload.calculated_area_value.to_f, epsilon = 0.0002
      end
    end
  end
end