class PlantRootstock < ActiveRecord::Base
  belongs_to :plant, class_name: 'Plant'
  belongs_to :rootstock, class_name: 'MasterVineVariety', foreign_key: :rootstock_id
end
