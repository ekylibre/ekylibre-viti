class CviCadastralPlant < ActiveRecord::Base
  belongs_to :cvi_statement

  validates :commune, :cadastral_reference, :product, :grape_variety, :area, :campaign,:inter_vine_plant_distance, :inter_row_distance, :state, presence: true
end
