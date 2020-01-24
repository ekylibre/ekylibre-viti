require 'test_helper'

class ConcatCviLandParcelsTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  describe('ConcatCviLandParcels.call') do
    let(:cvi_cultivable_zone) { create(:cvi_cultivable_zone) }
    let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2,:with_rootstock, name: 'name', cvi_cultivable_zone_id: cvi_cultivable_zone.id) }

    it 'sets cvi_land_parcel attributes correctly (attribute equals for all cvi_land_parcels  ? attribute value : nil)' do
      result = ConcatCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
      assert_equal cvi_land_parcels.first.name, result.cvi_land_parcel.name
      assert_empty result.cvi_land_parcel.attributes
                                            .except!(*%w[id name cvi_cultivable_zone_id calculated_area_unit declared_area_unit inter_vine_plant_distance_unit inter_row_distance_unit state])
                                            .values
                                            .compact
      assert_equal 1, result.cvi_land_parcel.land_parcel_rootstocks.length
    end

    describe 'roostock are not commons to all cvi_land_parcels' do 
      let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2,:with_rootstock, name: 'name', cvi_cultivable_zone_id: cvi_cultivable_zone.id) }
      
      it 'set rootstock_id to nil' do
        result = ConcatCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
        assert_nil result.cvi_land_parcel.land_parcel_rootstocks.first.rootstock_id
      end
    end

    describe 'roostock are commons to all cvi_land_parcels' do
      let(:cvi_land_parcel) { create_list(:cvi_land_parcel, 2,:with_rootstock, name: 'name', cvi_cultivable_zone_id: cvi_cultivable_zone.id) }

      it 'set rootstock_id to common rootstock_id' do
        cvi_land_parcels.collect(&:land_parcel_rootstocks).flatten.map{|lpr| lpr.update(rootstock_id: "123") }
        result = ConcatCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
        assert_equal "123" , result.cvi_land_parcel.land_parcel_rootstocks.first.rootstock_id
      end
    end
  end
end