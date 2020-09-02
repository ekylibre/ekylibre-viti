# = Informations
#
# == License
#
# Ekylibre - Simple agricultural ERP
# Copyright (C) 2008-2009 Brice Texier, Thibaud Merigon
# Copyright (C) 2010-2012 Brice Texier
# Copyright (C) 2012-2014 Brice Texier, David Joulin
# Copyright (C) 2015-2020 Ekylibre SAS
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
# == Table: wine_incoming_harvest_storages
#
#

class WineIncomingHarvestStorage < Ekylibre::Record::Base
  belongs_to :wine_incoming_harvest
  belongs_to :storage, class_name: 'Product'
  # [VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  # ]VALIDATORS]
  # before link campaign depends on received_at
  composed_of :quantity, class_name: 'Measure', mapping: [%w[quantity_value to_d], %w[quantity_unit unit]]
  refers_to :quantity_unit, class_name: 'Unit'
end
