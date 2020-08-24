class Crop
  include ActiveModel::Model

  def self.all
    Product.where(type: %w[LandParcel Plant])
  end
end