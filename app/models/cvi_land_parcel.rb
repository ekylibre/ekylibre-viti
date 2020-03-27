class CviLandParcel < Ekylibre::Record::Base
  include Shaped

  composed_of :calculated_area, class_name: 'Measure', mapping: [%w[calculated_area_value to_d], %w[calculated_area_unit unit]]
  composed_of :declared_area, class_name: 'Measure', mapping: [%w[declared_area_value to_d], %w[declared_area_unit unit]]
  composed_of :inter_row_distance, class_name: 'Measure', mapping: [%w[inter_row_distance_value to_d], %w[inter_row_distance_unit unit]]
  composed_of :inter_vine_plant_distance, class_name: 'Measure', mapping: [%w[inter_vine_plant_distance_value to_d], %w[inter_vine_plant_distance_unit unit]]

  belongs_to :cvi_cultivable_zone
  belongs_to :designation_of_origin, class_name: 'RegisteredProtectedDesignationOfOrigin', foreign_key: :designation_of_origin_id
  belongs_to :vine_variety, class_name: 'MasterVineVariety', foreign_key: :vine_variety_id
  has_many :locations, as: :localizable, dependent: :destroy
  validates :inter_row_distance_value, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 500 }, allow_blank: true
  validates :inter_vine_plant_distance_value, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 200 }, allow_blank: true
  has_many :land_parcel_rootstocks, as: :land_parcel, dependent: :destroy
  has_many :cvi_cadastral_plant_cvi_land_parcels, dependent: :destroy
  has_many :cvi_cadastral_plants, through: :cvi_cadastral_plant_cvi_land_parcels
  has_many :rootstocks, through: :cvi_cadastral_plants
  belongs_to :rootstock, class_name: 'MasterVineVariety', foreign_key: :rootstock_id

  accepts_nested_attributes_for :land_parcel_rootstocks, reject_if: proc { |attributes| attributes['rootstock_id'].blank? }

  enumerize :state, in: %i[planted removed_with_authorization], predicates: true

  validates_presence_of :name, :inter_row_distance_value, :inter_vine_plant_distance_value, :vine_variety_id

  def updated?
    updated_at != created_at
  end

  def valid_for_update_multiple?
    valid?
    errors.delete(:name)
    errors.delete(:inter_vine_plant_distance_value) if errors.added?(:inter_vine_plant_distance_value, :blank)
    errors.delete(:inter_row_distance_value) if errors.added?(:inter_row_distance_value, :blank)
    errors.delete(:vine_variety_id) if errors.added?(:vine_variety_id, :blank)
    errors.empty?
  end

  def regrouped?
    cvi_cadastral_plants.length > 1
  end
end
