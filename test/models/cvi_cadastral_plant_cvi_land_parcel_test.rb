require 'test_helper'

class CviCadastralPlantCviLandParcelTest < ActiveSupport::TestCase
  should 'be creatable' do
    resource = FactoryBot.create(:cvi_cadastral_plant_cvi_land_parcel)
    first_resource = CviCadastralPlantCviLandParcel.last
    assert_equal resource, first_resource
  end

  context 'associations' do
    should belong_to(:cvi_land_parcel)
    should belong_to(:cvi_cadastral_plant)
  end
end
