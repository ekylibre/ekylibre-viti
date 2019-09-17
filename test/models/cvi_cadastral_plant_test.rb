require 'test_helper'

class CviCadastralPlantTest < ActiveSupport::TestCase
  should 'be creatable' do
    cvi_cadastral_plant = create(:cvi_cadastral_plant)
    first_cvi_cadastral_plant = CviCadastralPlant.first
    assert_equal cvi_cadastral_plant, first_cvi_cadastral_plant
  end

  context 'validations' do
    should validate_presence_of(:commune)
    should validate_presence_of(:cadastral_reference)
    should validate_presence_of(:product)
    should validate_presence_of(:grape_variety)
    should validate_presence_of(:area)
    should validate_presence_of(:campaign)
    should validate_presence_of(:inter_vine_plant_distance)
    should validate_presence_of(:inter_row_distance)
    should validate_presence_of(:state)
  end

  context 'associations' do
    should belong_to(:cvi_statement)
  end
end
