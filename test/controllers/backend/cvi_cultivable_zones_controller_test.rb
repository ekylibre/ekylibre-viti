require 'test_helper'
module Backend
  class CviCultivableZonesControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions only: %i[edit destroy]

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
      ATTRIBUTES = %w[commune locality designation_of_origin_name vine_variety_name declared_area_value calculated_area_value declared_area_formatted calculated_area_formatted inter_vine_plant_distance_value inter_row_distance_value state rootstock shape].freeze


      it 'responds with success' do
        get :generate_cvi_land_parcels, id: cvi_cultivable_zone.id
        assert_response :success
      end

      it 'generate the same number of cvi_land_parcel as existing cvi_cadastral_plants' do
        assert_change 'CviLandParcel.count', cvi_cultivable_zone.cvi_cadastral_plants.count do
          get :generate_cvi_land_parcels, id: cvi_cultivable_zone.id
        end
      end

      it 'attributes value are correctly setted ' do
        get :generate_cvi_land_parcels, id: cvi_cultivable_zone.id
        cvi_land_parcel = CviLandParcel.last
        cvi_cadastral_plant = CviCadastralPlant.last
        assert_equal cvi_cadastral_plant.cadastral_reference, cvi_land_parcel.name
        assert_equal cvi_cadastral_plant.cvi_statement.campaign_id, cvi_land_parcel.campaign_id
        assert_equal (cvi_cadastral_plant.attributes.select { |key| ATTRIBUTES.include?(key) }), (cvi_land_parcel.attributes.select { |key| ATTRIBUTES.include?(key) })
      end
    end
  end
end