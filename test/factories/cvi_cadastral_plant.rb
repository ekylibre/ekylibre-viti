FactoryBot.define do
  factory :cvi_cadastral_plant do
    commune { Faker::Address.city }
    locality { Faker::Address.city }
    insee_number { Faker::Number.number(digits: 6) }
    work_number { Faker::Number.number(digits: 4) }
    section { %w(A,F,G).sample }
    land_parcel_number { Faker::Number.number(digits: 1) }
    measure_value_value { Faker::Number.decimal_part(digits: 3) }
    measure_value_unit { 'hectare' }
    campaign { Faker::Date.between(from: 10.years.ago, to: Date.today).year }
    land_parcel_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    designation_of_origin_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    vine_variety_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    rootstock_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    inter_vine_plant_distance { Faker::Number.number(digits: 3) }
    inter_row_distance { Faker::Number.number(digits: 3) }
    state { [:planted, :removed_with_authorization].sample }
    cvi_statement
  end
end