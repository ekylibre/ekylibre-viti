class Backend::CropGroupsController < Backend::BaseController
  manage_restfully

  def self.crop_groups_conditions
    code = ''
    code << search_conditions(crop_groups: %i[name target], labels: %i[name]) + " ||= []\n"
    # code << "unless params[:state].blank? \n"
    # code << "  c[0] << ' AND #{FormattedCviLandParcel.table_name}.state IN (?)'\n"
    # code << "  c << params[:state]\n"
    # code << "end\n"
    code << "c\n "
    code.c
  end

  list selectable: true, joins: %i[labels], conditions: crop_groups_conditions do |t|
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
