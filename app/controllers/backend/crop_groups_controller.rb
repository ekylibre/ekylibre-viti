class Backend::CropGroupsController < Backend::BaseController
  manage_restfully only: %i[index new edit create update destroy]

  list selectable: true, join: :crop_group_items do |t|
    t.action :edit
    t.action :destroy, if: :destroyable?
    t.column :name
    t.column :uses, label_method: :label_names, label: :usages 
    t.column :crop_names, label_method: :crop_names, label: :land_parcels_plants
    t.column :total_area, label_method: :total_area, label: :total_area
  end
end
