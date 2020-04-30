require 'test_helper'

class LocationTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  should 'be creatable' do
    resource = create(:location)
    first_resource = Location.last
    assert_equal resource, first_resource
  end

  context 'associations' do
    should belong_to(:localizable)
    should belong_to(:registered_postal_zone)
  end
end
