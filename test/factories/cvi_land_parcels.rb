FactoryBot.define do
  factory :cvi_land_parcel do
    name { FFaker::NameFR.name }
    declared_area_unit { :hectare }
    declared_area_value { BigDecimal(rand.round(2), 4) }
    inter_vine_plant_distance_value { BigDecimal(rand.round(2), 4) }
    inter_vine_plant_distance_unit { :centimeter }
    inter_row_distance_value { BigDecimal(rand.round(2), 4) }
    inter_row_distance_unit { :centimeter }
    designation_of_origin_id { RegisteredProtectedDesignationOfOrigin.order('RANDOM()').first.id }
    vine_variety_id { MasterVineVariety.where(category_name: 'Cépage').order('RANDOM()').first.id }
    state { %i[planted removed_with_authorization].sample }
    shape { FFaker::Shape.multipolygon.simplify(0.05) }
    planting_campaign { FFaker::Time.between(10.years.ago, Time.zone.today).year.to_s }
    land_modification_date { Time.zone.today - rand(10_000) }
    cvi_cultivable_zone
    with_location
    with_rootstock

    trait :old_splitted do
      shape {'POLYGON ((-0.2532838 45.77936779560541, -0.252766 45.78065979560589, -0.25263 45.78060929560586, -0.2531422999999999 45.77933279560539, -0.2532838 45.77936779560541))'}
    end

    trait :new_splitted do
      sequence(:shape) do |n|
        [
          'POLYGON ((-0.2532838 45.77936779560541, -0.2530568 45.77993679560561, -0.2530234355964364 45.7800197476819, -0.2528854767532964 45.77997453204999, -0.2529129 45.77990639560561, -0.2531422999999999 45.77933279560539, -0.2532838 45.77936779560541))',
          'POLYGON ((-0.2530234355964364 45.7800197476819, -0.252766 45.78065979560589, -0.25263 45.78060929560586, -0.2528854767532964 45.77997453204999, -0.2530234355964364 45.7800197476819))'
        ][n % 2]
      end
    end

    trait :with_location do
      after(:create) do |resource|
        create(:location, localizable: resource)
      end
    end

    trait :with_activity do
      activity
    end

    trait :with_rootstock do
      after(:create) do |resource|
        create(:land_parcel_rootstock, land_parcel: resource)
      end
    end

    trait :with_2_rootstocks do
      after(:create) do |resource|
        create_list(:land_parcel_rootstock,2, land_parcel: resource)
      end
    end

    trait :groupable do
      inter_vine_plant_distance_value { 1 }
      inter_row_distance_value { 2 }
      designation_of_origin_id { RegisteredProtectedDesignationOfOrigin.first.id }
      vine_variety_id { MasterVineVariety.where(category_name: 'Cépage').first.id }
      state { :planted }
      planting_campaign { '1900' }
    end
  end
end
