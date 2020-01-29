FactoryBot.define do
  factory :land_parcel_rootstock do
    rootstock_id { MasterVineVariety.where(category_name: 'Porte-greffe').order('RANDOM()').first.id }
    percentage { 1.0 }
    for_cvi_land_parcel

    trait :for_cvi_land_parcel do
      association :land_parcel, factory: :cvi_land_parcel
    end
  end
end