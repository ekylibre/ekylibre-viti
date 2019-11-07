class CviCultivableZone < Ekylibre::Record::Base
  include Shaped
  composed_of :calculated_area, class_name: 'Measure', mapping: [%w[calculated_area_value to_d], %w[calculated_area_unit unit]]
  composed_of :declared_area, class_name: 'Measure', mapping: [%w[declared_area_value to_d], %w[declared_area_unit unit]]

  belongs_to :cvi_statement
  has_many :cvi_cadastral_plants, dependent: :nullify

  validates_presence_of :name

  enumerize :land_parcels_status, in: %i[not_created created], predicates: true
end
