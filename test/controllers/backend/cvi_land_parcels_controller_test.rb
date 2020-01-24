require 'test_helper'

module Backend
  class CviLandParcelsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[edit_multiple update_multiple index update group split pre_split index]

    describe('#index') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone, :with_cvi_land_parcels) }

      it 'return the right number of cvi_land_parcel' do 
        get :index, id: cvi_cultivable_zone.id
        assert_equal cvi_cultivable_zone.cvi_land_parcels.count, JSON.parse(response.body).count
      end

      it 'return object with id, shape, updated? keys' do
        get :index, id: cvi_cultivable_zone.id
        assert_equal %w[uuid shape name updated], JSON.parse(response.body).first.keys
      end
    end

    describe('#update') do
      let(:cvi_land_parcel) { create(:cvi_land_parcel) }
      let(:attributes) { attributes_for(:cvi_land_parcel) }

      it 'updates record' do
        xhr :put, :update, id: cvi_land_parcel.id, cvi_land_parcel: attributes
        cvi_land_parcel = CviLandParcel.order('updated_at').last
        assert_equal attributes[:name], cvi_land_parcel.name
        assert_equal attributes[:planting_campaign], cvi_land_parcel.planting_campaign
        assert_equal attributes[:inter_vine_plant_distance_value], cvi_land_parcel.inter_vine_plant_distance_value
        assert_equal attributes[:inter_row_distance_value], cvi_land_parcel.inter_row_distance_value
        assert_equal attributes[:designation_of_origin_id], cvi_land_parcel.designation_of_origin_id
        assert_equal attributes[:vine_variety_id], cvi_land_parcel.vine_variety_id
        assert_equal attributes[:state].to_s, cvi_land_parcel.state
        assert_equal attributes[:shape], cvi_land_parcel.shape.to_rgeo
        assert_equal attributes[:planting_campaign], cvi_land_parcel.planting_campaign
        assert_equal attributes[:land_modification_date], cvi_land_parcel.land_modification_date
      end

      it 'responds with success' do
        xhr :put, :update, id: cvi_land_parcel.id, cvi_land_parcel: attributes
        assert_response :success
      end
    end

    describe('group') do
      describe('cvi_land_parcels are not groupable') do
        let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2) }

        it 'sets a flash message' do
          assert_difference 'flash.count', 1 do
            xhr :post, :group, cvi_land_parcel_ids: cvi_land_parcels.map(&:id)
          end
        end
      end

      describe('cvi_land_parcels are groupable') do
        let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2, :groupable) }

        it 'responds with success' do
          xhr :post, :group, cvi_land_parcel_ids: cvi_land_parcels.map(&:id)
          assert_response :success
        end
      end
    end

    describe('#edit_multiple') do
      let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2) }

      it 'responds with success' do
        xhr :get, :edit_multiple, ids: cvi_land_parcels.map(&:id)
        assert_response :success
      end

      it 'assigns objects' do
        xhr :get, :edit_multiple, ids: cvi_land_parcels.map(&:id)
        assert_not_nil assigns(:cvi_land_parcels)
        assert_not_nil assigns(:cvi_land_parcel)
        assert_not_nil assigns(:rootstock_editable)
      end
    end

    describe('#update_multiple') do
      let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }
      let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2, cvi_cultivable_zone_id: cvi_cultivable_zone.id) }
      let(:params) { attributes_for(:cvi_land_parcel, land_parcel_rootstocks_attributes: { '0' => attributes_for(:land_parcel_rootstock) }) }

      it 'responds with success' do
        xhr :put, :update_multiple, ids: cvi_land_parcels.map(&:id), cvi_land_parcel: params
        assert_response :success
      end

      it 'updates each cvi_land_parcels' do
        xhr :put, :update_multiple, ids: cvi_land_parcels.map(&:id), cvi_land_parcel: params
        updated_cvi_land_parcels = CviLandParcel.find(cvi_land_parcels.map(&:id))
        EXCEPTED_ATTRIBUTES = %w[id created_at updated_at declared_area_value shape calculated_area_value].freeze
        assert updated_cvi_land_parcels.first.attributes.except(*EXCEPTED_ATTRIBUTES) ==
               updated_cvi_land_parcels.second.attributes.except(*EXCEPTED_ATTRIBUTES)
      end
    end

    describe('#rootstock_editable?') do
      describe('one or more cvi_land_parcel has many rootstock') do
        let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2,:with_2_rootstocks) }
        
        it 'assigns @rootstock_editable to false' do
          @controller.instance_variable_set(:@cvi_land_parcels, cvi_land_parcels)
          @controller.send(:rootstock_editable?)
          refute @controller.instance_variable_get(:@rootstock_editable)
        end
      end

      describe('cvi_land_parcels has only one rootstock') do
        let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2) }

        it 'assigns @rootstock_editable to true' do
          @controller.instance_variable_set(:@cvi_land_parcels, cvi_land_parcels)
          @controller.send(:rootstock_editable?)
          assert @controller.instance_variable_get(:@rootstock_editable)
        end
      end
    end
  end
end
