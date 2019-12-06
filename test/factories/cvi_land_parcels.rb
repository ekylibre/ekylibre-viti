FactoryBot.define do
  factory :cvi_land_parcel do
    name { FFaker::NameFR.name }
    calculated_area_unit { :hectare }
    calculated_area_value { rand.round(2) }
    declared_area_unit { :hectare }
    declared_area_value { rand.round(2) }
    inter_vine_plant_distance_value { rand.round(2) }
    inter_vine_plant_distance_unit { :centimeter }
    inter_row_distance_value { rand.round(2) }
    inter_row_distance_unit { :centimeter }
    designation_of_origin_id { RegistredProtectedDesignationOfOrigin.order('RANDOM()').first.id }
    vine_variety_id { MasterVineVariety.where(category_name: 'Cépage').order('RANDOM()').first.id }
    rootstock_id { MasterVineVariety.where(category_name: 'Porte-greffe').order('RANDOM()').first.id }
    state { %i[planted removed_with_authorization].sample }
    shape { FFaker::Shape.multipolygon }
    planting_campaign { FFaker::Time.between(10.years.ago, Date.today).year }
    cvi_cultivable_zone
    with_location

    trait :with_location do
      after(:create) do |resource|
        create(:location, localizable: resource)
      end
    end
  end
end
