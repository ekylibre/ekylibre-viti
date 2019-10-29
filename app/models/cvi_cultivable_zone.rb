class CviCultivableZone < Ekylibre::Record::Base
  composed_of :calculated_area, class_name: 'Measure', mapping: [%w[calculated_area_value to_d], %w[calculated_area_unit unit]]

  belongs_to :cvi_statement
  has_many :cvi_cadastral_plants, dependent: :nullify

  validates_presence_of :name

  enumerize :land_parcels_status, in: %i[not_created created], predicates: true

  default_scope { includes(:cvi_cadastral_plants) }

  def communes
    cvi_cadastral_plants.pluck(:commune).uniq.join(', ')
  end

  def cadastral_references
    cvi_cadastral_plants.pluck(:work_number, :land_parcel_number)
                        .map { |e| !e[1].blank? ? e.join('-') : e[0] }
                        .join(', ')
  end

  def declared_area
    cvi_cadastral_plants.collect(&:area).sum
  end

  def declared_shape
    cvi_cadastral_plants.collect(&:shape).sum
  end
end
