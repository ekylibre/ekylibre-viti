FactoryBot.define do
  factory :cvi_cultivable_zone do
    sequence(:name) { |n| "Zone#{n}" }
    calculated_area_unit { :hectare }
    calculated_area_value { rand.round(2) }
    declared_area_unit { :hectare }
    declared_area_value { rand.round(2) }
    land_parcels_status { %i[not_created created].sample }
    shape { FFaker::Shape.multipolygon }
    cvi_statement
    with_location

    trait :with_location do
      after(:create) do |resource|
        create(:location, localizable: resource)
      end
    end

    trait :with_cvi_cadastral_plants do
      after(:create) do |cvi_cultivable_zone|
        create_list(:cvi_cadastral_plant, Random.rand(1..4), cvi_cultivable_zone: cvi_cultivable_zone)
      end
    end

    trait :with_cvi_land_parcels do
      after(:create) do |cvi_cultivable_zone|
        create_list(:cvi_land_parcel, Random.rand(1..4), cvi_cultivable_zone: cvi_cultivable_zone)
      end
    end

    trait :with_cvi_land_parcels_all_created do
      after(:create) do |cvi_cultivable_zone|
        create_list(:cvi_land_parcel, Random.rand(1..4), :with_activity, cvi_cultivable_zone: cvi_cultivable_zone)
      end
    end
  end
end
