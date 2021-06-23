require 'test_helper'

class SplitCviLandParcelTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  DIFFERENT_ATTRIBUTES = %w[id name vine_variety_id shape declared_area_value declared_area_unit calculated_area_value calculated_area_unit created_at updated_at lock_version creator_id updater_id].freeze

  setup do
    @cvi_land_parcel = create(:cvi_land_parcel, :old_splitted)
    @new_cvi_land_parcels_params = build_list(:cvi_land_parcel, 2, :new_splitted).map(&:attributes).map { |e| e.slice('name', 'vine_variety_id', 'shape') }
  end

  attr_reader :cvi_land_parcel, :new_cvi_land_parcels_params

  test '#call creates new objects with old record attributes' do
    old_cvi_land_parcel = cvi_land_parcel
    SplitCviLandParcel.call(cvi_land_parcel: cvi_land_parcel, new_cvi_land_parcels_params: new_cvi_land_parcels_params)
    new_cvi_land_parcel = CviLandParcel.last
    assert old_cvi_land_parcel.attributes.except(*DIFFERENT_ATTRIBUTES) == new_cvi_land_parcel.attributes.except(*DIFFERENT_ATTRIBUTES)
  end

  test '#call sets declared area values' do
    old_declared_area = cvi_land_parcel.declared_area
    SplitCviLandParcel.call(cvi_land_parcel: cvi_land_parcel, new_cvi_land_parcels_params: new_cvi_land_parcels_params)
    new_declared_area1 = CviLandParcel.last(2).first.declared_area
    new_declared_area2 = CviLandParcel.last(2).last.declared_area
    assert_in_delta old_declared_area.value, (new_declared_area1 + new_declared_area2).value, 0.001
  end

  test '#call creates 2 records and destroy 1' do
    cvi_land_parcel
    assert_difference 'CviLandParcel.count', 1 do
      SplitCviLandParcel.call(cvi_land_parcel: cvi_land_parcel, new_cvi_land_parcels_params: new_cvi_land_parcels_params)
    end
  end

  test '#call sets relations' do
    cvi_cadastral_plant = cvi_land_parcel.cvi_cadastral_plants.first
    old_cvi_land_parcel_locations = cvi_land_parcel.locations.map { |r| [r.registered_postal_zone_id, r.locality] }
    SplitCviLandParcel.call(cvi_land_parcel: cvi_land_parcel, new_cvi_land_parcels_params: new_cvi_land_parcels_params)
    new_cvi_land_parcel = CviLandParcel.last
    assert_equal old_cvi_land_parcel_locations, new_cvi_land_parcel.locations.pluck(:registered_postal_zone_id, :locality)
    assert_equal cvi_cadastral_plant.id, new_cvi_land_parcel.cvi_cadastral_plants.first.id
  end

  test '#calldestroys old record' do
    id = cvi_land_parcel.id
    SplitCviLandParcel.call(cvi_land_parcel: cvi_land_parcel, new_cvi_land_parcels_params: new_cvi_land_parcels_params)
    assert_raise(ActiveRecord::RecordNotFound) { CviLandParcel.find(id) }
  end
end
