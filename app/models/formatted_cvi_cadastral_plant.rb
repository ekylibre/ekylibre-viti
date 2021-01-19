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
# == Table: formatted_cvi_cadastral_plants
#
#  area_formatted                  :string
#  area_value                      :decimal(19, 4)
#  cadastral_reference             :text
#  campaign                        :string
#  commune                         :string
#  cvi_statement_id                :integer
#  designation_of_origin_name      :string
#  id                              :integer
#  inter_row_distance_value        :integer
#  inter_vine_plant_distance_value :integer
#  land_parcel_id                  :string
#  locality                        :string
#  rootstock                       :text
#  state                           :string
#  vine_variety_name               :string
#
class FormattedCviCadastralPlant < ApplicationRecord
  enumerize :state, in: %i[planted removed_with_authorization], predicates: true
end
