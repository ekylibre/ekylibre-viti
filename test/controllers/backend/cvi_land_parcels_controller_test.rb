require 'test_helper'
module Backend
  class CviLandParcelsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[show update index group pre_split split]

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
        assert_equal attributes[:rootstock_id], cvi_land_parcel.rootstock_id
        assert_equal attributes[:state].to_s, cvi_land_parcel.state
        assert_equal attributes[:shape], cvi_land_parcel.shape.to_rgeo
        assert_equal attributes[:planting_campaign], cvi_land_parcel.planting_campaign
      end

      it 'responds with success' do
        xhr :put, :update, id: cvi_land_parcel.id, cvi_land_parcel: attributes
        assert_response :success
      end
    end

    describe('group') do
      describe('cvi_land_parcels are not groupable ') do
        let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2) }

        it 'sets a flash message' do
          assert_difference 'flash.count', 1 do
            xhr :post, :group, cvi_land_parcel_ids: cvi_land_parcels.map(&:id)
          end
        end

        it "doesn't create or delete cvi_land_parcel" do
          xhr :post, :group, cvi_land_parcel_ids: cvi_land_parcels.map(&:id)
          assert_equal cvi_land_parcels, CviLandParcel.find(cvi_land_parcels.collect(&:id))
        end
      end

      describe('cvi_land_parcels are groupable ') do
        let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2, :groupable) }

        it 'create à new record from records with correct attributes' do
          name = cvi_land_parcels.map(&:name).sort.join(', ')
          xhr :post, :group, cvi_land_parcel_ids: cvi_land_parcels.map(&:id)
          cvi_land_parcel = CviLandParcel.last
          assert_equal cvi_land_parcels.map(&:declared_area).sum, cvi_land_parcel.declared_area
          assert_equal name, cvi_land_parcel.name
        end

        it 'set the percentage of each rootstocks' do
          total_area = cvi_land_parcels.sum(&:calculated_area)
          area_rootstock1 = cvi_land_parcels.first.calculated_area
          area_rootstock2 = cvi_land_parcels.second.calculated_area
          percentage1 = area_rootstock1 / total_area
          percentage2 = area_rootstock2 / total_area
          xhr :post, :group, cvi_land_parcel_ids: cvi_land_parcels.map(&:id)
          cvi_land_parcel = CviLandParcel.last
          assert_in_epsilon(percentage1, cvi_land_parcel.land_parcel_rootstocks.first.percentage, epsilon = 0.01)
          assert_in_epsilon(percentage2, cvi_land_parcel.land_parcel_rootstocks.second.percentage, epsilon = 0.01)
        end

        it 'destroy grouped cvi_land_parcels' do
          xhr :post, :group, cvi_land_parcel_ids: cvi_land_parcels.map(&:id)
          assert_raise 'ActiveRecord::RecordNotFound' do
            CviLandParcel.find(cvi_land_parcels.map(&:id))
          end
        end

        it 'responds with success' do
          xhr :post, :group, cvi_land_parcel_ids: cvi_land_parcels.map(&:id)
          assert_response :success
        end
      end
    end

    describe('split') do
      let(:cvi_land_parcel) { create(:cvi_land_parcel, :old_splitted) }
      let(:new_cvi_land_parcels_params) do
        params_list = build_list(:cvi_land_parcel, 2, :new_splitted).map(&:attributes).map { |e| e.slice('name', 'vine_variety_id', 'shape') }
        Hash[(0...params_list.length).zip params_list]
      end

      it 'create new objects with old record attributes' do
        DIFFERENT_ATTRIBUTES = %w[id name vine_variety_id shape declared_area_value declared_area_unit calculated_area_value calculated_area_unit created_at updated_at].freeze
        old_cvi_land_parcel = cvi_land_parcel
        xhr :post, :split, id: cvi_land_parcel.id, new_cvi_land_parcels: new_cvi_land_parcels_params
        new_cvi_land_parcel = CviLandParcel.last
        assert old_cvi_land_parcel.attributes.except(*DIFFERENT_ATTRIBUTES) == new_cvi_land_parcel.attributes.except(*DIFFERENT_ATTRIBUTES)
      end

      it 'set declared area values' do
        old_declared_area = cvi_land_parcel.declared_area
        xhr :post, :split, id: cvi_land_parcel.id, new_cvi_land_parcels: new_cvi_land_parcels_params
        new_declared_area1 = CviLandParcel.last(2).first.declared_area
        new_declared_area2 = CviLandParcel.last(2).last.declared_area
        assert_in_epsilon old_declared_area.value, (new_declared_area1 + new_declared_area2).value , epsilon = 0.001
      end

      it 'create 2 records and  destroy 1' do
        assert_difference 'CviLandParcel.count', 2 do
          xhr :post, :split, id: cvi_land_parcel.id, new_cvi_land_parcels: new_cvi_land_parcels_params
        end
      end

      it 'set relations' do
        old_cvi_land_parcel_locations = cvi_land_parcel.locations.map { |r| [r.insee_number, r.locality] }
        old_cvi_land_parcel_rootstocks = cvi_land_parcel.land_parcel_rootstocks.map { |r| [r.rootstock_id, r.percentage] }
        xhr :post, :split, id: cvi_land_parcel.id, new_cvi_land_parcels: new_cvi_land_parcels_params
        new_cvi_land_parcel = CviLandParcel.last
        assert_equal old_cvi_land_parcel_locations, new_cvi_land_parcel.locations.pluck(:insee_number, :locality)
        assert_equal old_cvi_land_parcel_rootstocks, new_cvi_land_parcel.land_parcel_rootstocks.pluck(:rootstock_id, :percentage)
      end

      it 'destroy old record' do
        id = cvi_land_parcel.id
        xhr :post, :split, id: cvi_land_parcel.id, new_cvi_land_parcels: new_cvi_land_parcels_params
        assert_raise(ActiveRecord::RecordNotFound) { CviLandParcel.find(id) }
      end
    end
  end
end
