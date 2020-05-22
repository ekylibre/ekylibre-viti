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

  def has_cvi_land_parcels?
    cvi_land_parcels.any?
  end

  def land_parcels_valid?
    !(cvi_land_parcels.pluck(:planting_campaign).include?("9999") ||
      cvi_land_parcels.pluck(:planting_campaign).include?("") ||
      cvi_land_parcels.pluck(:planting_campaign).include?(nil))
  end

  def update_shape!
    shape = CviLandParcel.select('st_astext(
                                    ST_Simplify(
                                      ST_UNION(
                                        ARRAY_AGG(
                                          array[
                                            ST_MakeValid(cvi_land_parcels.shape),
                                            ST_MakeValid(cvi_cultivable_zones.shape)
                                          ]
                                        )
                                      ), 0.000000001
                                    )
                                  ) AS shape').joins(:cvi_cultivable_zone).find_by(cvi_cultivable_zone_id: id).shape
    calculated_area = Measure.new(shape.area, :square_meter).convert(:hectare)
    update!(shape: shape.to_rgeo, calculated_area: calculated_area)
  end

  def complete!
    update!(land_parcels_status: :completed)
  end
end
