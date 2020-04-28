require 'test_helper'

class CropGroupTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  it 'is creatable' do
    resource = create(:crop_group)
    last_resource =  CropGroup.last
    assert_equal resource, last_resource
  end

  should have_many(:labellings)
  should have_many(:items)
  should have_many(:plants)
  should have_many(:land_parcels)

  should validate_presence_of(:name)
  should enumerize(:target).in(:plant, :land_parcel).with_predicates(true)
end
