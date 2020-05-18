class CropGroup < Ekylibre::Record::Base
  enumerize :target, in: %i[plant land_parcel], predicates: true, default: :plant

  has_many :labellings, class_name: 'CropGroupLabelling', dependent: :destroy
  has_many :items, class_name: 'CropGroupItem', dependent: :nullify
  has_many :plants, through: :items, source: :crop, source_type: 'Plant'
  has_many :land_parcels, through: :items, source: :crop, source_type: 'LandParcel'
  has_many :labels, through: :labellings

  validates :name, presence: true

  accepts_nested_attributes_for :labellings, allow_destroy: true
  accepts_nested_attributes_for :items, allow_destroy: true

  scope :available_crops, ->(ids, type = %w[Plant LandParcel]) { where(id: ids).collect { |crop_group| crop_group.crops.where(type: type).availables(at: (Time.zone.now - 1.hour)) }.flatten }
  scope :collection_labels, ->(ids, type = %w[plant land_parcel]) { where(id: ids, target: type).collect(&:labels).flatten }

  def crops
    Crop.all.joins(:crop_group_items)
           .where('crop_group_items.crop_group_id = ?', id)
  end

  def label_names
    labels.collect(&:name).sort.join(', ')
  end

  def crop_names
    crops.collect(&:name).sort.join(', ')
  end

  def total_area
    crops.collect(&:net_surface_area).sum.to_s(:ha_a_ca)
  end

  def duplicate
    transaction do
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
end
