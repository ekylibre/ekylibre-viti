FactoryBot.define do
  factory :cvi_statement do
    cvi_number { Faker::Number.number(digits: 10) }
    extraction_date { Faker::Date.between(from: 2.days.ago, to: Date.today) }
    siret_number { Faker::Company.french_siret_number }
    farm_name { Faker::Company }
    declarant { Faker::Artist.name }
    total_area { Faker::Number.decimal(l_digits: 2) }
    cadastral_plant_count { Faker::Number.number(digits: 2) }
    cadastral_sub_plant_count { Faker::Number.number(digits: 2) }
    state { ['planted, removed with autorization'].sample }
  end
end
