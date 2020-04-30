class CropGroup < Ekylibre::Record::Base 
  enumerize :target, in: %i[land_parcel plant], default: :plant

  has_many :labellings, class_name: 'CropGroupLabelling', dependent: :destroy
  has_many :items, class_name: 'CropGroupItem', dependent: :nullify 
  has_many :plants, through: :items, source: :crop, source_type: 'Plant'
  has_many :land_parcels, through: :items, source: :crop, source_type: 'LandParcel'
  has_many :labels, through: :labellings

  validates :name, presence: true

  accepts_nested_attributes_for :labellings, allow_destroy: true
  accepts_nested_attributes_for :items, allow_destroy: true

  def crops 
    plants + land_parcels
  end

  def label_names
    labels.collect(&:name).join('')
  end

  def crop_names
    crops.collect(&:name).join('')
  end

  def total_area
    crops.collect(&:net_surface_area).sum
  end
end
