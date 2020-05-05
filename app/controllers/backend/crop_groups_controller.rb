class Backend::CropGroupsController < Backend::BaseController
  manage_restfully

  list selectable: true, join: :crop_group_items do |t|
    t.action :edit
    t.action :destroy, if: :destroyable?
    t.action :duplicate, method: :post
    t.column :name, url: true
    t.column :uses, label_method: :label_names, label: :usages 
    t.column :crop_names, label_method: :crop_names, label: :land_parcels_plants
    t.column :total_area, label_method: :total_area, label: :total_area
  end

  def duplicate
    return unless @crop_group = find_and_check

    @crop_group.duplicate
    redirect_to action: :index
  end
end
