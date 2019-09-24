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
#  campaign                  :string           not null
#  commune                   :string           not null
#  created_at                :datetime         not null
#  cvi_statement_id          :integer
#  designation_of_origin_id  :string
#  id                        :integer          not null, primary key
#  insee_number              :string           not null
#  inter_row_distance        :integer          not null
#  inter_vine_plant_distance :integer          not null
#  land_parcel_id            :string
#  land_parcel_number        :string
#  locality                  :string
#  measure_value_unit        :string
#  measure_value_value       :decimal(19, 4)
#  rootstock_id              :string
#  section                   :string           not null
#  state                     :string           not null
#  updated_at                :datetime         not null
#  vine_variety_id           :string
#  work_number               :string           not null
#
class CviCadastralPlant < Ekylibre::Record::Base
  composed_of :measure_value, class_name: 'Measure', mapping: [%w[measure_value_value to_d], %w[measure_value_unit unit]]

  enumerize :state, in: %i[planted removed_with_authorization],  predicates: true

  belongs_to :cvi_statement
  belongs_to :land_parcel, class_name: 'CadastralLandParcelZone', foreign_key: :land_parcel_id
  belongs_to :designation_of_origin, class_name: 'RegistredProtectedDesignationOfOrigin', foreign_key: :designation_of_origin_id
  belongs_to :vine_variety, class_name: 'MasterVineVariety', foreign_key: :vine_variety_id
  belongs_to :rootstock, class_name: 'MasterVineVariety', foreign_key: :rootstock_id

  validates :commune, :insee_number,:work_number,:section, :campaign, :inter_vine_plant_distance, :inter_row_distance, :state, presence: true
  validates :measure_value_value, numericality: { greater_than: -1_000_000_000_000_000, less_than: 1_000_000_000_000_000 }, allow_blank: true

  def cadastral_reference
    base = insee_number + section + work_number
    if land_parcel_number.blank?
      base
    else
      base + '-' + land_parcel_number
    end
  end

  def area_formated
    measure_value.to_s(:ha_ar_ca)
  end

  delegate :geographic_area, to: :designation_of_origin
  alias_method :designation_of_origin_name, :geographic_area

  delegate :specie_name, to: :vine_variety
  alias_method :vine_variety_name, :specie_name

  delegate :customs_code,to: :rootstock
  alias_method :rootstock_number, :customs_code

end
