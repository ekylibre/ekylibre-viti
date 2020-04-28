class CropGroupLabelling < Ekylibre::Record::Base
  belongs_to :crop_group
  belongs_to :label
end
