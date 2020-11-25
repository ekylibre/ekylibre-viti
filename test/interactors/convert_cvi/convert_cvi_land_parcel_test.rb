require 'test_helper'

module ConvertCvi
  class ConvertCviLandParcelTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
    setup do
      @cvi_statement = create(:cvi_statement, :with_one_cvi_cultivable_zone_ready_to_convert)
      @cvi_land_parcel = cvi_statement.cvi_land_parcels.first
      @activity_open_from = cvi_statement.campaign.harvest_year
      @converter = ConvertCvi::ConvertCviLandParcel.new(@cvi_land_parcel, @activity_open_from)
    end

    attr_reader :cvi_statement, :cvi_land_parcel, :activity_open_from, :converter

    test 'create a new activity production with correct attributes' do
      converter.call
      activity = cvi_land_parcel.activity
      created_activity_production = ActivityProduction.last
      assert_equal 'headland_cultivation', created_activity_production.support_nature
      assert_equal 'fruit', created_activity_production.usage
      assert_equal Campaign.of(cvi_land_parcel.planting_campaign), created_activity_production.planting_campaign
      assert_equal 'headland_cultivation', created_activity_production.support_nature
      assert_equal Hash['cvi_land_parcel_id', cvi_land_parcel.id], created_activity_production.providers
      assert_equal Date.new(cvi_land_parcel.planting_campaign.to_i - 1, activity.production_started_on.month, activity.production_started_on.day),
                   created_activity_production.started_on
      assert_equal Date.new(cvi_land_parcel.planting_campaign.to_i + activity.life_duration.to_i, activity.production_stopped_on.month, activity.production_stopped_on.day),
                   created_activity_production.stopped_on
    end

    test 'open_activity for all campaign from the planting campaign to the next campaign' do
      converter.instance_variable_set(:@activity_open_from, Time.zone.now.year - 5)
      converter.send(:open_activity)
      assert_equal 7, cvi_land_parcel.activity.budgets.count
    end

    test 'open_activity for current campaign if planted in current campaign ' do
      converter.instance_variable_set(:@activity_open_from, Time.zone.now.year)
      converter.send(:open_activity)
      assert_equal 1, cvi_land_parcel.activity.budgets.count
      assert_equal Time.zone.now.year, cvi_land_parcel.activity.budgets.first.campaign.harvest_year
    end

    test 'use existing activity_production if a production with the same shape already exist' do
      activity_production = create(:activity_production, activity: cvi_land_parcel.activity, support_shape: Charta.new_geometry("SRID=4326;MULTIPOLYGON (((-0.9428286552429199 43.77818419848836, -0.9408894181251525 43.777330143623416, -0.9400096535682678 43.77828102933575, -0.9415814280509949 43.778892996664055, -0.9428286552429199 43.77818419848836)))") )
      cvi_land_parcel.update(shape: Charta.new_geometry('SRID=4326;MULTIPOLYGON (((-0.9428286552429199 43.77818419848836, -0.9408894181251525 43.777330143623416, -0.9400096535682678 43.77828102933575, -0.9415814280509949 43.778892996664055, -0.9428286552429199 43.77818419848836)))').to_rgeo)
      assert_difference 'ActivityProduction.count', 0 do
        converter.send(:find_or_create_production)
      end
    end

    test 'use existing activity_production if a production with the same provider already exist' do
      activity_production = create(:activity_production, activity: cvi_land_parcel.activity, providers: { cvi_land_parcel_id: cvi_land_parcel.id } )
      assert_difference 'ActivityProduction.count', 0 do
        converter.send(:find_or_create_production)
      end
    end

    test 'create a new plant with correct attributes' do
      cvi_land_parcel.update(state: :removed_with_authorization, planting_campaign: '1999', land_modification_date: Date.new(2000, 4, 5))
      cvi_land_parcel.cvi_cadastral_plants.first.update(type_of_occupancy: 'tenant_farming')
      converter.call
      vine_variety = cvi_land_parcel.vine_variety
      created_plant = Plant.last
      specie_variety = { 'specie_variety_name' => vine_variety.short_name, 'specie_variety_uuid' => vine_variety.id, 'specie_variety_providers' => vine_variety.class.name }
      assert_equal cvi_land_parcel.shape, created_plant.initial_shape
      assert_equal Date.new(2000, 4, 5), created_plant.initial_dead_at
      assert_equal 'rent', created_plant.type_of_occupancy
      assert_nil created_plant.initial_owner
      assert_equal specie_variety, created_plant.specie_variety
      assert_equal cvi_land_parcel.inter_row_distance_value.in(cvi_land_parcel.inter_row_distance_unit.to_sym), created_plant.rows_interval
      assert_equal cvi_land_parcel.inter_vine_plant_distance_value.in(cvi_land_parcel.inter_vine_plant_distance_unit.to_sym), created_plant.plants_interval
      assert_equal cvi_land_parcel.designation_of_origin.product_human_name_fra, created_plant.certification_label
    end
  end
end
