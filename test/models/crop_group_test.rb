require 'test_helper'

class CropGroupTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  it 'is creatable' do
    resource = create(:crop_group)
    last_resource = CropGroup.last
    assert_equal resource, last_resource
  end

  should have_many(:labellings)
  should have_many(:items)
  should have_many(:plants)
  should have_many(:land_parcels)

  should validate_presence_of(:name)
  should enumerize(:target).in(:plant, :land_parcel).with_predicates(true)

  describe '#duplicate' do
    let(:crop_group) { create(:crop_group)}
    it 'create a new crop_group' do
      duplicate_crop_group = crop_group.duplicate
      assert_equal duplicate_crop_group , CropGroup.last
    end
    it 'creates à new crop_group with correct attribute' do
      duplicate_crop_group = crop_group.duplicate
      assert_equal crop_group.name + ' (1)', duplicate_crop_group.name
      assert_equal crop_group.target, duplicate_crop_group.target
      assert_equal crop_group.labels.pluck(:id), duplicate_crop_group.labels.pluck(:id)
      assert_equal crop_group.crops.collect(&:id), duplicate_crop_group.crops.collect(&:id)
    end
  end
end
