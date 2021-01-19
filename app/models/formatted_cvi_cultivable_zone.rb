class FormattedCviCultivableZone < ApplicationRecord
  self.primary_key = 'id'

  enumerize :land_parcels_status, in: %i[not_started started completed], predicates: true

  has_many :cvi_land_parcels, foreign_key: :cvi_cultivable_zone_id
  
  def has_cvi_land_parcels?
    cvi_land_parcels.any?
  end
end
