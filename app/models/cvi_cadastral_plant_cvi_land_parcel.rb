class CviCadastralPlantCviLandParcel < ActiveRecord::Base
  belongs_to :cvi_land_parcel
  belongs_to :cvi_cadastral_plant
end
