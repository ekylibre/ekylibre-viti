require 'test_helper'

class ConcatCviLandParcelsTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  setup do
    @cvi_cultivable_zone = create(:cvi_cultivable_zone)
    create_cvi_land_parcels
    while same_attributes?(@cvi_land_parcels)
      create_cvi_land_parcels
    end
  end

  attr_reader :cvi_cultivable_zone, :cvi_land_parcels

  test 'ConcatCviLandParcels.call sets cvi_land_parcel attributes correctly (attribute equals for all cvi_land_parcels  ? attribute value : nil)' do
    result = ConcatCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
    assert_equal cvi_land_parcels.first.name, result.cvi_land_parcel.name
    assert_empty result.cvi_land_parcel.attributes
                       .except!('id', 'name', 'cvi_cultivable_zone_id', 'calculated_area_unit', 'declared_area_unit', 'inter_vine_plant_distance_unit', 'inter_row_distance_unit', 'state')
                       .values
                       .compact
  end

  private

  def create_cvi_land_parcels
    @cvi_land_parcels = create_list(:cvi_land_parcel, 2, name: 'name', cvi_cultivable_zone_id: cvi_cultivable_zone.id)
  end

  def same_attributes?(cvi_land_parcels)
    cvi_land_parcel1 = cvi_land_parcels.first
    cvi_land_parcel2 = cvi_land_parcels.second
    cvi_land_parcels.first.attributes.except!('id', 'name', 'cvi_cultivable_zone_id', 'calculated_area_unit', 'declared_area_unit', 'inter_vine_plant_distance_unit', 'inter_row_distance_unit', 'state').keys.any? do |attribute|
      cvi_land_parcel1.send(attribute) == cvi_land_parcel2.send(attribute)
    end
  end
end
