class LandParcelRootstock < ActiveRecord::Base
  belongs_to :rootstock, foreign_key: :rootstock_id
  belongs_to :land_parcel, polymorphic: true
end
