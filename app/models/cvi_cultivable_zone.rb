class CviCultivableZone < Ekylibre::Record::Base
  include Shaped

  composed_of :calculated_area, class_name: 'Measure', mapping: [%w[calculated_area_value to_d], %w[calculated_area_unit unit]]
  composed_of :declared_area, class_name: 'Measure', mapping: [%w[declared_area_value to_d], %w[declared_area_unit unit]]

  belongs_to :cvi_statement
  has_many :cvi_cadastral_plants, dependent: :nullify
  has_many :cvi_land_parcels, dependent: :destroy
  has_many :locations, as: :localizable, dependent: :destroy

  validates_presence_of :name

  enumerize :land_parcels_status, in: %i[not_started started not_created created completed], predicates: true

  after_save :set_calculated_area, on: %i[create update], if: :shape_changed?

  def has_cvi_land_parcels?
    cvi_land_parcels.any?
  end

  def land_parcels_valid?
    !(cvi_land_parcels.pluck(:planting_campaign).include?("9999") ||
      cvi_land_parcels.pluck(:planting_campaign).include?("") ||
      cvi_land_parcels.pluck(:planting_campaign).include?(nil))
  end

  def update_shape!
    update!(shape: shape.to_rgeo)
  end
  
  def shape=(value = shape)
    new_shape = if has_cvi_land_parcels?
                  CviLandParcel.select("st_astext(
                                          ST_Simplify(
                                            ST_UNION(
                                              ARRAY_AGG(
                                                array[
                                                  ST_MakeValid(cvi_land_parcels.shape),
                                                  ST_MakeValid(
                                                    ST_GeomFromText(\'#{value.as_text}\')
                                                  )
                                                ]
                                              )
                                            ), 0.000000001
                                          )
                                        ) AS shape").joins(:cvi_cultivable_zone).find_by(cvi_cultivable_zone_id: id).shape.to_rgeo
                else
                  value
                end

    super(new_shape)
  end

  def complete!
    update!(land_parcels_status: :completed)
  end
end
