class CviLandParcel < Ekylibre::Record::Base
  composed_of :calculated_area, class_name: 'Measure', mapping: [%w[calculated_area_value to_d], %w[calculated_area_unit unit]]
  composed_of :declared_area, class_name: 'Measure', mapping: [%w[declared_area_value to_d], %w[declared_area_unit unit]]
  composed_of :inter_row_distance, class_name: 'Measure', mapping: [%w[inter_row_distance_value to_d], %w[inter_row_distance_unit unit]]
  composed_of :inter_vine_plant_distance, class_name: 'Measure', mapping: [%w[inter_vine_plant_distance_value to_d], %w[inter_vine_plant_distance_unit unit]]

  belongs_to :campaign
  belongs_to :cvi_cultivable_zone
  belongs_to :designation_of_origin, class_name: 'RegistredProtectedDesignationOfOrigin', foreign_key: :designation_of_origin_id
  belongs_to :vine_variety, class_name: 'VineVariety', foreign_key: :vine_variety_id
  belongs_to :rootstock, class_name: 'Rootstock', foreign_key: :rootstock_id

  enumerize :state, in: %i[planted removed_with_authorization], predicates: true

  validates_presence_of :name
  def updated?
    updated_at != created_at
  end
end
