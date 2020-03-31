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
      let(:cvi_land_parcels) { create_list(:cvi_land_parcel, 2, :groupable, :new_splitted) }

      it 'create à new record from records with correct attributes' do
        name = cvi_land_parcels.map(&:name).sort.join(', ')
        GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
        cvi_land_parcel = CviLandParcel.last
        assert_equal cvi_land_parcels.map(&:declared_area).sum, cvi_land_parcel.declared_area
        assert_in_delta cvi_land_parcels.map(&:calculated_area_value).sum, cvi_land_parcel.calculated_area.value, 0.001
        assert_equal name, cvi_land_parcel.name
      end

      it 'set the percentage' do
        total_area = cvi_land_parcels.sum(&:declared_area)
        area_rootstock1 = cvi_land_parcels.first.cvi_cadastral_plants.first.area
        area_rootstock2 = cvi_land_parcels.second.cvi_cadastral_plants.first.area
        percentage1 = area_rootstock1 / total_area
        percentage2 = area_rootstock2 / total_area
        GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
        cvi_land_parcel = CviLandParcel.last
        assert_in_delta(percentage1, cvi_land_parcel.cvi_cadastral_plant_cvi_land_parcels.first.percentage, delta = 0.01)
        assert_in_delta(percentage2, cvi_land_parcel.cvi_cadastral_plant_cvi_land_parcels.second.percentage, delta = 0.01)
      end

      it 'set the main rootstock and the main campaign' do
        GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
        cvi_land_parcel = CviLandParcel.last
        main_cvi_cadastral_plant = cvi_land_parcel.cvi_cadastral_plants.order(:area_value).last
        assert_equal main_cvi_cadastral_plant.planting_campaign, cvi_land_parcel.planting_campaign
        assert_equal main_cvi_cadastral_plant.rootstock_id , cvi_land_parcel.rootstock_id
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
