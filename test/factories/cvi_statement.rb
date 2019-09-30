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
end
