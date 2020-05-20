FactoryBot.define do
  factory :label do
    color {'red'}
    name { FFaker::NameFR.name }
  end
end