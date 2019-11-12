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
#  campaign_id               :integer
#  created_at                :datetime         not null
#  cvi_number                :string           not null
#  declarant                 :string           not null
#  extraction_date           :date             not null
#  farm_name                 :string           not null
#  id                        :integer          not null, primary key
#  siret_number              :string           not null
#  state                     :string           not null
#  total_area_unit           :string
#  total_area_value          :decimal(19, 4)
#  updated_at                :datetime         not null
#

class CviStatement < Ekylibre::Record::Base
  composed_of :total_area, class_name: 'Measure', mapping: [%w[total_area_value to_d], %w[total_area_unit unit]]
  enumerize :state, in: %i[to_convert converted], default: :to_convert, predicates: true

  validates :extraction_date, :siret_number, :farm_name, :declarant, :state, presence: true
  validates :siret_number, siret_format: true
  validates :total_area_value, numericality: { greater_than: -1_000_000_000_000_000, less_than: 1_000_000_000_000_000 }, allow_blank: true

  belongs_to :campaign
  has_many :cvi_cadastral_plants, dependent: :destroy
  has_many :cvi_cultivable_zone, dependent: :destroy

  def total_area_formated
    total_area.to_s(:ha_ar_ca)
  end
end
