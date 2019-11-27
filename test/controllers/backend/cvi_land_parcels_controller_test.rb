require 'test_helper'
module Backend
  class CviLandParcelsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[show update index]

    describe('#index') do
      let(:cvi_land_parcel) { create_list(:cvi_land_parcel, 3) }

      it 'return the right number of cvi_land_parcel' do 
        get :index, cvi_cultivable_zone_id: cvi_land_parcel.cvi_cultivable_zone_id
        assert_equal 3, JSON.parse(response.body).count
      end

      it 'return object with id, shape, updated? keys' do
        get :index, cvi_cultivable_zone_id: cvi_land_parcel.cvi_cultivable_zone_id
        assert_equal %w[id shape updated], JSON.parse(response.body).first.keys
      end 
    end

    describe('#update') do
      let(:cvi_land_parcel) { create(:cvi_land_parcel) }

      it 'updates record' do
        xhr :put, :update, id: cvi_land_parcel.id, cvi_land_parcel: attributes_for(;cvi_land_parcel)
        assert_equal 'new_name', cvi_land_parcel.reload.name
      end

      it 'responds with success' do
        xhr :put, :update, id: cvi_land_parcel.id, cvi_land_parcel: { name: 'new_name' }
        assert_response :success
      end
    end
  end
end
