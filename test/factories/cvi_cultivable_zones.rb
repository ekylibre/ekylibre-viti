FactoryBot.define do
  factory :cvi_cultivable_zone do
    sequence(:name) { |n| "Zone#{n}" }
    calculated_area_unit { :hectare }
    calculated_area_value { rand.round(2) }
    land_parcels_status { %i[not_created created].sample }
    shape { "" }
    cvi_statement

    trait :with_cvi_cadastral_plants do
      after(:create) do |cvi_cultivable_zone|
        create_list(:cvi_cadastral_plant, Random.rand(1..4), cvi_cultivable_zone: cvi_cultivable_zone)
      end
    end
  end
end
