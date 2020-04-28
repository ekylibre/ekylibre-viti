require 'test_helper'

class CropGroupLabellingTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  it 'is creatable' do
    resource = create(:crop_group_labelling)
    last_resource =  CropGroupLabelling.last
    assert_equal resource, last_resource
  end

  should belong_to(:crop_group)
  should belong_to(:label)
end
