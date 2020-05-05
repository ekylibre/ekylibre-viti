FactoryBot.define do
  factory :crop_group do
    name { FFaker::NameFR.name }
    target { %i[plant land_parcel].sample.to_sym }
    with_labelings
    with_items

    trait :with_items do
      after(:create) do |crop_group|
        create_list(:crop_group_item, Random.rand(1..3), crop_group: crop_group)
      end
    end

    trait :with_labelings do
      after(:create) do |crop_group|
        create_list(:crop_group_item, Random.rand(1..3), crop_group: crop_group)
      end
    end
  end
end