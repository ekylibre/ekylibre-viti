class CropGroup < Ekylibre::Record::Base
  enumerize :target, in: %i[land_parcel plant], predicates: true, default: :plant

  has_many :labellings, class_name: 'CropGroupLabelling', dependent: :destroy
  has_many :items, class_name: 'CropGroupItem', dependent: :nullify
  has_many :plants, through: :items, source: :crop, source_type: 'Plant'
  has_many :land_parcels, through: :items, source: :crop, source_type: 'LandParcel'
  has_many :labels, through: :labellings

  validates :name, presence: true

  accepts_nested_attributes_for :labellings, allow_destroy: true
  accepts_nested_attributes_for :items, allow_destroy: true

  def crops
    Product.joins(:crop_group_items)
           .where("products.type IN ('Plant', 'LandParcel') AND crop_group_items.crop_group_id = #{id} AND crop_group_items.crop_type IN ('Plant', 'LandParcel')")
  end

  def label_names
    labels.collect(&:name).sort.join(', ')
  end

  def crop_names
    crops.collect(&:name).sort.join(', ')
  end

  def total_area
    crops.collect(&:net_surface_area).sum
  end

  def duplicate
    index = self.class.where('name like ?', "#{name}%").count
    crop_group = self.class.create!(attributes.merge(name: "#{name} (#{index})").delete_if { |a| a.to_s == 'id' })
    items.each do |item|
      item.duplicate(crop_group)
    end
    labellings.each do |labelling|
      labelling.duplicate(crop_group)
    end
    crop_group
  end
end
