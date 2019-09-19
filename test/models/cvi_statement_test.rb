# = Informations
#
# == License
#
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2009 Brice Texier, Thibaud Merigon
# Copyright (C) 2010-2012 Brice Texier
# Copyright (C) 2012-2019 Brice Texier, David Joulin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see http://www.gnu.org/licenses.
#
# == Table: cvi_statements
#
#  cadastral_plant_count     :integer          default(0)
#  cadastral_sub_plant_count :integer          default(0)
#  created_at                :datetime         not null
#  cvi_number                :string           not null
#  declarant                 :string           not null
#  extraction_date           :date             not null
#  farm_name                 :string           not null
#  id                        :integer          not null, primary key
#  siret_number              :string           not null
#  state                     :string           not null
#  total_area                :decimal(, )
#  updated_at                :datetime         not null
#
require 'test_helper'

class CviStatementTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
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

  should enumerize(:state).in(:to_convert, :converted).with_default(:to_convert).with_predicates(true)

  context '#total_area_formated' do
    should 'format area' do
      cvi_statement = create(:cvi_statement, total_area: 1.1456)
      assert_equal '01 HA 14 AR 56 CA', cvi_statement.total_area_formated
    end
  end
end
