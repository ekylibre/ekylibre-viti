require 'test_helper'
require_relative '../../test_helper'

module Backend
  class CviLandParcelsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[edit_multiple update_multiple index update group split pre_split index new_vine_activity_params]

    setup do
      @cvi_cultivable_zone = create(:cvi_cultivable_zone, :with_cvi_land_parcels)
      @cvi_land_parcel = create(:cvi_land_parcel, :with_activity)
      activity = create(:activity)
      @attributes = attributes_for(:cvi_land_parcel, activity_id: activity.id)
    end

    attr_reader :cvi_cultivable_zone, :cvi_land_parcel, :attributes

    test '#index' do
      get :index,  params: { id: cvi_cultivable_zone.id }
      assert_equal cvi_cultivable_zone.cvi_land_parcels.count, JSON.parse(response.body).count, 'return the right number of cvi_land_parcel'
      assert_equal %w[uuid shape name year vine_variety updated], JSON.parse(response.body).first.keys, 'return object with id, shape, updated? keys'
    end

    test '#update updates record et respond with success' do
      put :update, params: { id: cvi_land_parcel.id, cvi_land_parcel: attributes }, xhr: true
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
      assert_response :success
    end

    test('#group when cvi_land_parcels are not groupable, it sets a flash message') do
      cvi_land_parcels = create_list(:cvi_land_parcel, 2)
      assert_difference 'flash.count', 1, 'sets a flash message' do
        post :group, params: { cvi_land_parcel_ids: cvi_land_parcels.map(&:id) }, xhr: true
      end
    end

    test('#group when cvi_land_parcels are groupable respon with success') do
      cvi_land_parcels = create_list(:cvi_land_parcel, 2, :groupable)
      post :group, params: { cvi_land_parcel_ids: cvi_land_parcels.map(&:id) }, xhr: true
      assert_response :success
    end

    test('#edit_multiple') do
      cvi_land_parcels = create_list(:cvi_land_parcel, 2)
      get :edit_multiple, params: { ids: cvi_land_parcels.map(&:id) }, xhr: true
      assert_response :success, 'responds with success'
      assert_not_nil assigns(:cvi_land_parcels)
      assert_not_nil assigns(:cvi_land_parcel)
    end

    test('#update_multiple') do
      cvi_cultivable_zone = create(:cvi_cultivable_zone)
      cvi_land_parcels =  create_list(:cvi_land_parcel, 2, cvi_cultivable_zone_id: cvi_cultivable_zone.id)
      put :update_multiple, params: { ids: cvi_land_parcels.map(&:id), cvi_land_parcel: attributes }, xhr: true
      updated_cvi_land_parcels = CviLandParcel.find(cvi_land_parcels.map(&:id))
      EXCEPTED_ATTRIBUTES = %w[id created_at updated_at declared_area_value shape calculated_area_value].freeze
      assert updated_cvi_land_parcels.first.attributes.except(*EXCEPTED_ATTRIBUTES) ==
             updated_cvi_land_parcels.second.attributes.except(*EXCEPTED_ATTRIBUTES)
      assert_response :success, 'responds with success'
    end
  end
end
