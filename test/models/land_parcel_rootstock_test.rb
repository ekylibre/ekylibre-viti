require 'test_helper'

class LandParcelRootstockTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  should 'be creatable' do
    resource = create(:location)
    first_resource = Location.last
    assert_equal resource, first_resource
  end

  context 'associations' do
    should belong_to(:land_parcel)
    should belong_to(:rootstock)
  end
end
