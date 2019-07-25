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
# == Table: registered_pfi_doses
#
#  active         :integer          not null
#  crop_id        :integer          not null
#  dose_quantity  :decimal(19, 4)
#  dose_unity     :string
#  functions      :string
#  harvest_year   :integer          not null
#  maaid          :integer          not null
#  pesticide_name :string
#  target_id      :integer
#
require 'test_helper'

class RegisteredPfiDoseTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  # Add tests here...
end
