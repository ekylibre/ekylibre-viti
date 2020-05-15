class CropGroupItem < Ekylibre::Record::Base
  belongs_to :crop_group
  belongs_to :crop, polymorphic: true

  def duplicate(new_crop_group)
    self.class.create!(attributes.merge(crop_group: new_crop_group).delete_if { |a| a.to_s == 'id' })
  end
end
