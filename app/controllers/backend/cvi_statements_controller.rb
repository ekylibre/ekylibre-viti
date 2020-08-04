module Backend
  class CviStatementsController < Backend::CviBaseController
    manage_restfully

    def self.cvi_statements_conditions
      code = ''
      code = search_conditions(cvi_statements: %i[cvi_number declarant farm_name]) + " ||= []\n"
      code << "c\n "
      code.c
    end

    def self.cvi_cadastral_plants_conditions
      code = ''
      code = search_conditions(formatted_cvi_cadastral_plants: %i[state designation_of_origin_name vine_variety_name cadastral_reference commune locality rootstock]) + " ||= []\n"

      code << "c[0] << ' AND #{FormattedCviCadastralPlant.table_name}.cvi_statement_id = ?'\n"
      code << "c << params[:id].to_i\n"

      # state
      code << "unless params[:state].blank? \n"
      code << "  c[0] << ' AND #{FormattedCviCadastralPlant.table_name}.state IN (?)'\n"
      code << "  c << params[:state]\n"
      code << "end\n"

      # area
      code << "if params[:area] \n"
      code << "  lower,higher = params[:area].split(',').map(&:to_f)\n"
      code << "  c[0] << ' AND #{FormattedCviCadastralPlant.table_name}.area_value BETWEEN ? AND ?'\n"
      code << "  c << lower\n"
      code << "  c << higher\n"
      code << "end\n"

      # # designation_of_origin_name
      code << "unless params[:designation_of_origin_name].blank? \n"
      code << "  c[0] << ' AND #{FormattedCviCadastralPlant.table_name}.designation_of_origin_name = ?'\n"
      code << "  c << params[:designation_of_origin_name]\n"
      code << "end\n"

      # # vine_variety_name
      code << "unless params[:vine_variety_name].blank? \n"
      code << "  c[0] << ' AND #{FormattedCviCadastralPlant.table_name}.vine_variety_name = ?'\n"
      code << "  c << params[:vine_variety_name]\n"
      code << "end\n"

      # inter_row_distance
      code << "if params[:inter_row_distance_value] \n"
      code << "  lower,higher = params[:inter_row_distance_value].split(',').map(&:to_i)\n"
      code << "  c[0] << ' AND #{FormattedCviCadastralPlant.table_name}.inter_row_distance_value BETWEEN ? AND ?'\n"
      code << "  c << lower\n"
      code << "  c << higher\n"
      code << "end\n"

      # inter_vine_plant_distance
      code << "if params[:inter_vine_plant_distance_value]\n"
      code << "  lower,higher = params[:inter_vine_plant_distance_value].split(',').map(&:to_i)\n"
      code << "  c[0] << ' AND #{FormattedCviCadastralPlant.table_name}.inter_vine_plant_distance_value BETWEEN ? AND ?'\n"
      code << "  c << lower\n"
      code << "  c << higher\n"
      code << "end\n"

      code << "c\n "
      code.c
    end

    list(conditions: cvi_statements_conditions) do |t|
      t.action :edit
      t.action :destroy, if: :destroyable?
      t.column :cvi_number, url: true
      t.column :extraction_date
      t.column :created_at
      t.column :declarant
      t.column :farm_name
      t.column :total_area, datatype: :measure, label_method: :total_area_formatted
      t.column :state
    end

    list(:cvi_cadastral_plants, order: 'land_parcel_id DESC', model: :formatted_cvi_cadastral_plants, conditions: cvi_cadastral_plants_conditions,
                                line_class: "('invalid' unless RECORD.land_parcel_id) || ('edited' if RECORD.cadastral_ref_updated)".c) do |t|
      t.column :land_parcel_id, hidden: true
      t.action :edit, url: { controller: 'cvi_cadastral_plants', action: 'edit', remote: true }
      t.action :delete_modal, url: { controller: 'cvi_cadastral_plants', action: 'delete_modal', remote: true }, icon_name: 'delete'
      t.column :commune
      t.column :locality
      t.column :cadastral_reference
      t.column :designation_of_origin_name
      t.column :vine_variety_name
      t.column :area_formatted
      t.column :planting_campaign
      t.column :rootstock
      t.column :inter_vine_plant_distance_value
      t.column :inter_row_distance_value
      t.column :state
    end
  end
end
