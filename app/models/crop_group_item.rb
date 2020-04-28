class CropGroupItem < Ekylibre::Record::Base
  belongs_to :crop_group
  belongs_to :crop, polymorphic: true
end
