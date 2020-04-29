class CropGroupLabelling < Ekylibre::Record::Base
  include Labellable
  belongs_to :crop_group
end
