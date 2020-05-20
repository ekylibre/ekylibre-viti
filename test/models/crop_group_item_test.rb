require 'test_helper'

class CropGroupItemTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  it 'is creatable' do
    resource = create(:crop_group_item)
    last_resource = CropGroupItem.last
    assert_equal resource, last_resource
  end

  should belong_to(:crop_group)
  should belong_to(:crop)
end
