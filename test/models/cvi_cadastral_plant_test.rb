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
#  campaign                  :string           not null
#  commune                   :string           not null
#  created_at                :datetime         not null
#  cvi_statement_id          :integer
#  designation_of_origin_id  :string
#  grape_variety             :string           not null
#  id                        :integer          not null, primary key
#  insee_number              :string           not null
#  inter_row_distance        :integer          not null
#  inter_vine_plant_distance :integer          not null
#  land_parcel_id            :string
#  land_parcel_number        :string
#  locality                  :string
#  product                   :string           not null
#  rootstock                 :string
#  section                   :string           not null
#  state                     :string           not null
#  updated_at                :datetime         not null
#  vine_variety_id           :string
#  work_number               :string           not null
#
require 'test_helper'

class CviCadastralPlantTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  should 'be creatable' do
    cvi_cadastral_plant = create(:cvi_cadastral_plant)
    first_cvi_cadastral_plant = CviCadastralPlant.last
    assert_equal cvi_cadastral_plant, first_cvi_cadastral_plant
  end

  context 'validations' do
    should validate_presence_of(:commune)
    should validate_presence_of(:section)
    should validate_presence_of(:work_number)
    should validate_presence_of(:product)
    should validate_presence_of(:grape_variety)
    should validate_presence_of(:area)
    should validate_presence_of(:campaign)
    should validate_presence_of(:inter_vine_plant_distance)
    should validate_presence_of(:inter_row_distance)
    should validate_presence_of(:state)
    should validate_presence_of(:insee_number)
  end

  context 'associations' do
    should belong_to(:cvi_statement)
    should belong_to(:land_parcel)
    should belong_to(:designation_of_origin).with_foreign_key('designation_of_origin_id')
    should belong_to(:vine_variety).with_foreign_key('vine_variety_id')
  end

  should enumerize(:state).in(:planted, :removed_with_authorization).with_predicates(true)
end
