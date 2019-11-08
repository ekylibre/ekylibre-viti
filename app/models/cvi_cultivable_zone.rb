class CviCultivableZone < Ekylibre::Record::Base
  composed_of :calculated_area, class_name: 'Measure', mapping: [%w[calculated_area_value to_d], %w[calculated_area_unit unit]]
  composed_of :declared_area, class_name: 'Measure', mapping: [%w[declared_area_value to_d], %w[declared_area_unit unit]]

  belongs_to :cvi_statement
  has_many :cvi_cadastral_plants, dependent: :nullify

  before_save :set_formatted_declared_area, if: :declared_area_changed?
  before_save :set_formatted_calculated_area, if: :calculated_area_changed?

  validates_presence_of :name

  enumerize :land_parcels_status, in: %i[not_created created], predicates: true

  def shape
    Charta.new_geometry(self[:shape])
  end

  private 

  def declared_area_changed?
    (declared_area_value && !formatted_declared_area) || declared_area_value_changed? || declared_area_value_changed?
  end

  def calculated_area_changed?
    (calculated_area_value && !formatted_calculated_area)  || calculated_area_value_changed? || calculated_area_value_changed?
  end

  def set_formatted_calculated_area
    self.formatted_calculated_area = Measure.new(calculated_area_value,calculated_area_unit).to_s(:ha_a_ca)
  end

  def set_formatted_declared_area
    self.formatted_declared_area = Measure.new(declared_area_value,declared_area_unit).to_s(:ha_a_ca)
  end
end
