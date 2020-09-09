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
# == Table: wine_incoming_harvests
#
#

class WineIncomingHarvest < Ekylibre::Record::Base
  include Attachable
  belongs_to :analysis, class_name: 'Analysis'
  belongs_to :campaign, class_name: 'Campaign'
  has_many :inputs, class_name: 'WineIncomingHarvestInput', dependent: :destroy
  has_many :plants, class_name: 'WineIncomingHarvestPlant', dependent: :destroy
  has_many :storages, class_name: 'WineIncomingHarvestStorage', dependent: :destroy
  # [VALIDATORS[ Do not edit these lines directly. Use `rake clean:validations`.
  validates :received_at, timeliness: { on_or_after: -> { Time.new(1, 1, 1).in_time_zone }, on_or_before: -> { Time.zone.now + 50.years } }, allow_blank: true
  validates :ticket_number, :number, length: { maximum: 500 }, allow_blank: true
  # ]VALIDATORS]
  composed_of :quantity, class_name: 'Measure', mapping: [%w[quantity_value to_d], %w[quantity_unit unit]]
  acts_as_numbered :number, readonly: false

  refers_to :quantity_unit, class_name: 'Unit'

  accepts_nested_attributes_for :plants
  accepts_nested_attributes_for :storages

  serialize :additional_informations, HashSerializer
  store_accessor :additional_informations, :pressing_schedule, :pressing_started_at, :sedimentation_duration, :vehicle_trailer, :harvest_transportation_duration, :last_load, :harvest_nature, :harvest_dock

  # before link campaign depends on received_at
  before_validation do
    self.campaign = Campaign.on(received_at)
  end

  after_destroy do
    analysis.reload
    analysis.destroy!
  end

  def tavp
    analysis&.items&.find_by(indicator_name: :estimated_harvest_alcoholic_volumetric_concentration)&.value&.round_l
  end
end
