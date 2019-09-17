require 'test_helper'

class CviStatementTest < ActiveSupport::TestCase
  should 'be creatable' do
    cvi_statement = create(:cvi_statement)
    first_cvi_statement = CviStatement.first
    assert_equal cvi_statement, first_cvi_statement
  end

  context 'with wrong siret number format' do
    should 'not create record' do
      cvi_statement = build(:cvi_statement, siret_number: 12_323_131)
      refute cvi_statement.valid?
    end
  end

  context 'validations' do
    should validate_presence_of(:extraction_date)
    should validate_presence_of(:siret_number)
    should validate_presence_of(:farm_name)
    should validate_presence_of(:declarant)
    should validate_presence_of(:state)
  end

  context 'associations' do
    should have_many(:cvi_cadastral_plants)
  end

  context '#total_area_formated' do
    should 'format area' do
      cvi_statement = create(:cvi_statement, total_area: 1.1456)
      assert_equal '01 HA 14 AR 56 CA', cvi_statement.total_area_formated
    end
  end
end
