require 'test_helper'

class GroupCviCultivableZonesTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures

  describe('GroupCviCultivableZonesTest.call') do
    describe('cvi_cultivable_zones are not groupable') do
      let(:cvi_cultivable_zones) { create_list(:cvi_cultivable_zone, 2) }

      it "doesn't create or delete cvi_cultivable_zone" do
        GroupCviCultivableZones.call(cvi_cultivable_zones: cvi_cultivable_zones)
        assert_equal cvi_cultivable_zones, CviCultivableZone.find(cvi_cultivable_zones.collect(&:id))
      end
    end

    describe('cvi_cultivable_zones are groupable') do
      let(:cvi_cultivable_zones) { create_list(:cvi_cultivable_zone, 2, :new_splitted, :with_cvi_land_parcels, :with_cvi_cadastral_plants) }

      it 'create à new record from records with correct attributes' do
        name = cvi_cultivable_zones.map(&:name).sort.join(', ')
        locations = cvi_cultivable_zones.flat_map(&:locations)
        cvi_land_parcels = cvi_cultivable_zones.flat_map(&:cvi_land_parcels)
        cvi_cadastral_plants = cvi_cultivable_zones.flat_map(&:cvi_cadastral_plants)
        result = GroupCviCultivableZones.call(cvi_cultivable_zones: cvi_cultivable_zones)
        cvi_cultivable_zone = result.new_cvi_cultivable_zone
        assert_equal cvi_cultivable_zones.map(&:declared_area).sum, cvi_cultivable_zone.declared_area
        assert_equal name, cvi_cultivable_zone.name
        assert_equal locations, cvi_cultivable_zone.locations
        assert_equal cvi_land_parcels, cvi_cultivable_zone.cvi_land_parcels
        assert_equal cvi_cadastral_plants, cvi_cultivable_zone.cvi_cadastral_plants
      end

      it 'destroy grouped cvi_cultivable_zones' do
        GroupCviCultivableZones.call(cvi_cultivable_zones: cvi_cultivable_zones)
        assert_raise 'ActiveRecord::RecordNotFound' do
          CviCultivableZone.find(cvi_cultivable_zones.map(&:id))
        end
      end

      describe('one of cvi_cultivable_zones don\'t have any cvi_land_parcels  created yet') do
        let(:cvi_cultivable_zone1) { create(:cvi_cultivable_zone, :old_splitted, :with_cvi_cadastral_plants) }
        let(:cvi_cultivable_zone2) { create(:cvi_cultivable_zone, :old_splitted, :with_cvi_cadastral_plants, :with_cvi_land_parcels) }

        it 'generate new cvi_land_parcels associated to the new cvi_cultivable_zone' do
          cvi_land_parcels_count = cvi_cultivable_zone1.cvi_cadastral_plants.count + cvi_cultivable_zone2.cvi_land_parcels.count
          result = GroupCviCultivableZones.call(cvi_cultivable_zones: [cvi_cultivable_zone1, cvi_cultivable_zone2])
          assert_equal cvi_land_parcels_count, result.new_cvi_cultivable_zone.cvi_land_parcels.count
        end
      end
    end
  end
end
