class CropGroupLabelling < Ekylibre::Record::Base
  include Labellable
  belongs_to :crop_group

  def duplicate(new_crop_group)
    self.class.create!(attributes.merge(crop_group: new_crop_group).delete_if { |a| a.to_s == 'id' })
  end
end
