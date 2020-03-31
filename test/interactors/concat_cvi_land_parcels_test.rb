require 'test_helper'

class ConcatCviLandParcelsTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  describe('ConcatCviLandParcels.call') do
    let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }
    let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2, name: 'name', cvi_cultivable_zone_id: cvi_cultivable_zone.id) }

    it 'sets cvi_land_parcel attributes correctly (attribute equals for all cvi_land_parcels  ? attribute value : nil)' do
      result = ConcatCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
      assert_equal cvi_land_parcels.first.name, result.cvi_land_parcel.name
      assert_empty result.cvi_land_parcel.attributes
                                            .except!(*%w[id name cvi_cultivable_zone_id calculated_area_unit declared_area_unit inter_vine_plant_distance_unit inter_row_distance_unit state])
                                            .values
                                            .compact
    end
  end
end