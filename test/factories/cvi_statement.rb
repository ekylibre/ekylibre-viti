FactoryBot.define do
  factory :cvi_statement do
    cvi_number { Faker::Number.number(digits: 10) }
    extraction_date { Faker::Date.between(from: 2.days.ago, to: Date.today) }
    siret_number { Faker::Company.french_siret_number }
    farm_name { Faker::Company }
    declarant { Faker::Artist.name }
    measure_value_value { Faker::Number.decimal_part(digits: 3) }
    measure_value_unit { 'hectare' }
    cadastral_plant_count { Faker::Number.number(digits: 2) }
    cadastral_sub_plant_count { Faker::Number.number(digits: 2) }
    state { [:to_convert, :converted].sample.to_sym }
  end
end
