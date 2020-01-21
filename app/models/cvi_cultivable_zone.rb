class CviCultivableZone < Ekylibre::Record::Base
  composed_of :calculated_area, class_name: 'Measure', mapping: [%w[calculated_area_value to_d], %w[calculated_area_unit unit]]
  composed_of :declared_area, class_name: 'Measure', mapping: [%w[declared_area_value to_d], %w[declared_area_unit unit]]

  belongs_to :cvi_statement
  has_many :cvi_cadastral_plants, dependent: :nullify
  has_many :cvi_land_parcels, dependent: :destroy
  has_many :locations, as: :localizable, dependent: :destroy

  validates_presence_of :name

  before_save :set_calculated_area, on: %i[create update], if: :shape_changed?

  enumerize :land_parcels_status, in: %i[not_created created], predicates: true

  def shape
    Charta.new_geometry(self[:shape])
  end

  def has_cvi_land_parcels?
    cvi_land_parcels.any?
  end

  def set_calculated_area
    self.calculated_area = Measure.new(shape.area, :square_meter).convert(:hectare)
  end
end
