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
# == Table: cvi_cadastral_plants
#
#  area                      :string           not null
#  cadastral_reference       :string           not null
#  campaign                  :string           not null
#  commune                   :string           not null
#  created_at                :datetime         not null
#  cvi_statement_id          :integer
#  grape_variety             :string           not null
#  id                        :integer          not null, primary key
#  inter_row_distance        :integer          not null
#  inter_vine_plant_distance :integer          not null
#  locality                  :string
#  product                   :string           not null
#  rootstock                 :string
#  state                     :string           not null
#  updated_at                :datetime         not null
#
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
