FactoryBot.define do
  factory :activity do
    sequence(:name)  { |n| "Fake Activity #{n}" }
    family           { :plant_farming }
    production_cycle { :annual }
    production_started_on { Date.today - rand(10000) }
    production_stopped_on { Date.today + rand(10000) }
  end

  trait :perennial do
    production_cycle { :perennial }
    start_state_of_production { {"3": "n_3_4_leaf"} }
    life_duration { 30 }
  end

  factory :corn_activity, class: Activity do
    sequence(:name)  { |n| "Corn - TEST#{n.to_s.rjust(8, '0')}" }
    family           { :plant_farming }
    production_cycle { :annual }

    trait :fully_inspectable do
      use_gradings { true }
      measure_grading_sizes { true }
      grading_sizes_indicator_name { :length }
      grading_sizes_unit_name { 'centimeter' }
      measure_grading_net_mass { true }
      grading_net_mass_unit_name { 'kilogram' }
      measure_grading_items_count { true }

      after(:create) do |instance|
        create :ugly_point_natures,          activity: instance
        create :sick_point_natures,          activity: instance

        create :width_grading_scale,         activity: instance
        create :length_grading_scale,        activity: instance

        create :corn_inspection,             activity: instance
      end
    end
  end
end
