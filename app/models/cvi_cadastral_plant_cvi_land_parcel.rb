class CviCadastralPlantCviLandParcel < ActiveRecord::Base
  belongs_to :cvi_land_parcel
  belongs_to :cvi_cadastral_plant

  before_save :set_percentage

  def set_percentage
    self.percentage = cvi_cadastral_plant.area / cvi_land_parcel.declared_area
  end
end
