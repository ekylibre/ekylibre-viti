FactoryBot.define do
  factory :cvi_land_parcel do
    name { FFaker::NameFR.name }
    calculated_area_unit { :hectare }
    calculated_area_value {}
    declared_area_unit { :hectare }
    declared_area_value { BigDecimal(rand.round(2), 4) }
    inter_vine_plant_distance_value { BigDecimal(rand.round(2), 4) }
    inter_vine_plant_distance_unit { :centimeter }
    inter_row_distance_value { BigDecimal(rand.round(2), 4) }
    inter_row_distance_unit { :centimeter }
    designation_of_origin_id { RegistredProtectedDesignationOfOrigin.order('RANDOM()').first.id }
    vine_variety_id { MasterVineVariety.where(category_name: 'Cépage').order('RANDOM()').first.id }
    rootstock_id { MasterVineVariety.where(category_name: 'Porte-greffe').order('RANDOM()').first.id }
    state { %i[planted removed_with_authorization].sample }
    shape { FFaker::Shape.multipolygon }
    planting_campaign { FFaker::Time.between(10.years.ago, Date.today).year.to_s }
    cvi_cultivable_zone
    with_location
    with_rootstock

    before(:create) do |cvi_land_parcel|
      cvi_land_parcel.calculated_area_value = Measure.new(cvi_land_parcel.shape.area, :square_meter).in(:hectare).to_f
    end

    trait :with_location do
      after(:create) do |resource|
        create(:location, localizable: resource)
      end
    end

    trait :with_rootstock do
      after(:create) do |resource|
        create(:land_parcel_rootstock, land_parcel: resource)
      end
    end

    trait :groupable do
      inter_vine_plant_distance_value { 1 }
      inter_row_distance_value { 2 }
      designation_of_origin_id { RegistredProtectedDesignationOfOrigin.first.id }
      vine_variety_id { MasterVineVariety.where(category_name: 'Cépage').first.id }
      state { :planted }
      planting_campaign { '1900' }
    end
  end
end
