FactoryBot.define do
  factory :cvi_cadastral_plant do
    commune { FFaker::AddressFR.city }
    locality { FFaker::AddressFR.city }
    insee_number { rand(1_000_000) }
    work_number { rand(5) }
    section { %w[A F G].sample }
    designation_of_origin_id { RegistredProtectedDesignationOfOrigin.order('RANDOM()').first.id }
    vine_variety_id { MasterVineVariety.where(category_name: 'Cépage').order('RANDOM()').first.id }
    rootstock_id { MasterVineVariety.where(category_name: 'Porte-greffe').order('RANDOM()').first.id }
    land_parcel_id { CadastralLandParcelZone.order('RANDOM()').first.id }
    land_parcel_number { rand(10) }
    area_value { rand.round(2) }
    area_unit { :hectare }
    inter_vine_plant_distance_value { rand.round(2) }
    inter_vine_plant_distance_unit { :centimeter }
    inter_row_distance_value { rand.round(2) }
    inter_row_distance_unit { :centimeter }
    campaign { FFaker::Time.between(10.years.ago, Date.today).year }
    state { %i[planted removed_with_authorization].sample }
    type_of_occupancy { %i[tenant_farming owner].sample }
    cvi_statement
  end
end

