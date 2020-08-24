class LandParcelRootstock < ActiveRecord::Base
  belongs_to :rootstock, class_name: 'MasterVineVariety', foreign_key: :rootstock_id
  belongs_to :land_parcel, polymorphic: true
end
