require 'test_helper'

class GenerateCviLandParcelsTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  ATTRIBUTES = %w[commune locality planting_campaign designation_of_origin_id vine_variety_id inter_vine_plant_distance_value inter_row_distance_value inter_vine_plant_distance_unit inter_row_distance_unit state rootstock_id].freeze

  setup do
    @cvi_cultivable_zone = create(:cvi_cultivable_zone, :with_cvi_cadastral_plants)
  end

  attr_reader :cvi_cultivable_zone

  test "GenerateCviLandParcels.call generates the same number of cvi_land_parcel as existing cvi_cadastral_plants" do
    assert_difference 'CviLandParcel.count', cvi_cultivable_zone.cvi_cadastral_plants.count do
      GenerateCviLandParcels.call(cvi_cultivable_zone: cvi_cultivable_zone)
    end
  end

  test 'GenerateCviLandParcels.call correctly sets attributes value' do
    GenerateCviLandParcels.call(cvi_cultivable_zone: cvi_cultivable_zone)
    assert_equal cvi_cultivable_zone.cvi_cadastral_plants.collect(&:cadastral_reference).sort, cvi_cultivable_zone.cvi_land_parcels.collect(&:name).sort
    cvi_cadastral_plant = CviCadastralPlant.last
    cvi_land_parcel = CviLandParcel.find_by(name: cvi_cadastral_plant.cadastral_reference)
    assert_equal Charta.new_geometry(cvi_cadastral_plant.shape.to_rgeo.simplify(0)), cvi_land_parcel.shape
  end

  test 'GenerateCviLandParcels.call simplify shape without changing area' do
    GenerateCviLandParcels.call(cvi_cultivable_zone: cvi_cultivable_zone)
    cvi_cadastral_plant = CviCadastralPlant.last
    cvi_land_parcel = CviLandParcel.find_by(name: cvi_cadastral_plant.cadastral_reference)
    assert_equal :polygon, cvi_land_parcel.shape.type
    assert_in_delta cvi_cadastral_plant.shape.area, cvi_land_parcel.shape.area, 0.00001
  end
end
