require 'test_helper'

class GroupCviLandParcelsTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  ATTRIBUTES = %i[designation_of_origin_id vine_variety_id inter_vine_plant_distance_value inter_row_distance_value planting_campaign state].freeze

  describe('GroupCviLandParcelsTest.call') do
    describe('cvi_land_parcels are not groupable') do
      let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2) }

      it "doesn't create or delete cvi_land_parcel" do
        GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
        assert_equal cvi_land_parcels, CviLandParcel.find(cvi_land_parcels.collect(&:id))
      end
    end

    describe('cvi_land_parcels are groupable') do
      let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2, :groupable,:new_splitted) }

      it 'create à new record from records with correct attributes' do
        name = cvi_land_parcels.map(&:name).sort.join(', ')
        GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
        cvi_land_parcel = CviLandParcel.last
        assert_equal cvi_land_parcels.map(&:declared_area).sum, cvi_land_parcel.declared_area
        assert_in_delta cvi_land_parcels.map(&:calculated_area_value).sum, cvi_land_parcel.calculated_area.value, 0.001
        assert_equal name, cvi_land_parcel.name
      end

      it 'set the percentage of each rootstocks' do
        total_area = cvi_land_parcels.sum(&:calculated_area)
        area_rootstock1 = cvi_land_parcels.first.calculated_area
        area_rootstock2 = cvi_land_parcels.second.calculated_area
        percentage1 = area_rootstock1 / total_area
        percentage2 = area_rootstock2 / total_area
        GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
        cvi_land_parcel = CviLandParcel.last
        assert_in_delta(percentage1, cvi_land_parcel.land_parcel_rootstocks.first.percentage, delta = 0.01)
        assert_in_delta(percentage2, cvi_land_parcel.land_parcel_rootstocks.second.percentage, delta = 0.01)
      end

      it 'destroy grouped cvi_land_parcels' do
        GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
        assert_raise 'ActiveRecord::RecordNotFound' do
          CviLandParcel.find(cvi_land_parcels.map(&:id))
        end
      end
    end
  end
end
