FactoryBot.define do
  factory :cvi_statement do
    cvi_number { rand(10_000_000) }
    extraction_date { FFaker::Time.date }
    siret_number { Luhn.generate(14) }
    farm_name { FFaker::Company.name }
    declarant { FFaker::NameFR.name }
    total_area { Measure.new(rand(1_000), :hectare) }
    cadastral_plant_count { rand(100) }
    cadastral_sub_plant_count { rand(100) }
    state { %i[to_convert converted].sample.to_sym }
  end

  trait :with_cvi_cadastral_plants do
    after(:create) do |cvi_statement|
      create_list(:cvi_cadastral_plant, Random.rand(1..4), cvi_statement: cvi_statement)
    end
  end

  trait :with_cvi_cultivable_zone do
    after(:create) do |cvi_statement|
      create(:cvi_cultivable_zone, cvi_statement: cvi_statement)
    end
  end
end
