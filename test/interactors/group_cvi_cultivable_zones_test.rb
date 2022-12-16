require 'test_helper'

class GroupCviCultivableZonesTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  test('#call if cvi_cultivable_zones are not groupable ') do
    cvi_cultivable_zones = create_list(:cvi_cultivable_zone, 2)
    GroupCviCultivableZones.call(cvi_cultivable_zones: cvi_cultivable_zones)
    assert_equal cvi_cultivable_zones, CviCultivableZone.find(cvi_cultivable_zones.collect(&:id)), "it doesn't create or delete cvi_cultivable_zone"
  end

  test('#call if cvi_cultivable_zones are groupable, it create à new record from records with correct attributes') do
    cvi_cultivable_zones = create_list(:cvi_cultivable_zone, 2, :new_splitted, :with_cvi_land_parcels, :with_cvi_cadastral_plants)
    name = cvi_cultivable_zones.map(&:name).sort.join(', ')
    locations = cvi_cultivable_zones.flat_map(&:locations)
    cvi_land_parcels = cvi_cultivable_zones.flat_map(&:cvi_land_parcels)
    cvi_cadastral_plants = cvi_cultivable_zones.flat_map(&:cvi_cadastral_plants)
    result = GroupCviCultivableZones.call(cvi_cultivable_zones: cvi_cultivable_zones)
    cvi_cultivable_zone = result.new_cvi_cultivable_zone
    assert_equal cvi_cultivable_zones.map(&:declared_area).sum, cvi_cultivable_zone.declared_area, 'Declared areas are equals'
    assert_equal name, cvi_cultivable_zone.name, 'Names are equals'
    assert_equal locations, cvi_cultivable_zone.locations, 'Locations are equals'
    assert_equal cvi_land_parcels.pluck(:id).sort, cvi_cultivable_zone.cvi_land_parcels.pluck(:id).sort, 'Cvi land parcels are associated to cvi cultivable zone'
    assert_equal cvi_cadastral_plants.pluck(:id).sort, cvi_cultivable_zone.cvi_cadastral_plants.pluck(:id).sort, 'Cvi cadastral plants are associated to cvi cultivable zone'
  end

  test('#call if cvi_cultivable_zones are groupable, it destroy grouped cvi_cultivable_zones') do
    GroupCviCultivableZones.call(cvi_cultivable_zones: cvi_cultivable_zones)
    assert_empty CviCultivableZone.where(id: cvi_cultivable_zones.map(&:id))
  end

  test('#call if cvi_cultivable_zones are groupable, and one of cvi_cultivable_zones don\'t have any cvi_land_parcels  created yet') do
    cvi_cultivable_zone1 = create(:cvi_cultivable_zone, :old_splitted, :with_cvi_cadastral_plants)
    cvi_cultivable_zone2 = create(:cvi_cultivable_zone, :old_splitted, :with_cvi_cadastral_plants, :with_cvi_land_parcels)

    cvi_land_parcels_count = cvi_cultivable_zone1.cvi_cadastral_plants.count + cvi_cultivable_zone2.cvi_land_parcels.count
    result = GroupCviCultivableZones.call(cvi_cultivable_zones: [cvi_cultivable_zone1, cvi_cultivable_zone2])
    assert_equal cvi_land_parcels_count, result.new_cvi_cultivable_zone.cvi_land_parcels.count, 'generate new cvi_land_parcels associated to the new cvi_cultivable_zone'
  end
end
