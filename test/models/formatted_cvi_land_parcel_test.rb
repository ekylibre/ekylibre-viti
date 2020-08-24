require 'test_helper'

class FormattedCviLandParcelTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  should enumerize(:state).in(:planted, :removed_with_authorization).with_predicates(true)

  should 'have the correct column names' do
    column_names = %w[id name commune locality designation_of_origin_name vine_variety_name declared_area_value calculated_area_value declared_area_formatted calculated_area_formatted inter_vine_plant_distance_value inter_row_distance_value state rootstock cvi_cultivable_zone_id]
    assert_equal column_names, FormattedCviLandParcel.column_names
  end
end
