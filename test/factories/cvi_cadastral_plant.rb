FactoryBot.define do
  factory :cvi_cadastral_plant do
    commune { FFaker::AddressFR.city }
    locality { FFaker::AddressFR.city }
    insee_number { rand(1_000_000) }
    work_number { rand(5) }
    section { %w[A F G].sample }
    land_parcel_number { rand(10) }
    area_value { rand.round(2) }
    area_unit { :hectare }
    inter_vine_plant_distance_value { rand.round(2) }
    inter_vine_plant_distance_unit { :centimeter }
    inter_row_distance_value { rand.round(2) }
    inter_row_distance_unit { :centimeter }
    campaign { FFaker::Time.between(10.years.ago, Date.today).year }
    land_parcel_id { rand(36**10).to_s(36) }
    designation_of_origin_id { rand(36**10).to_s(36) }
    vine_variety_id { rand(36**10).to_s(36) }
    rootstock_id { rand(36**10).to_s(36) }
    state { %i[planted removed_with_authorization].sample }
    type_of_occupancy { %i[tenant_farming owner].sample }
    cvi_statement
  end
end

