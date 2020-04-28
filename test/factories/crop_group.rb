FactoryBot.define do
  factory :crop_group do
    name { FFaker::NameFR.name }
    target { %i[plant land_parcel].sample.to_sym }
  end
end