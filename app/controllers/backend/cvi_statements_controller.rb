module Backend
  class CviStatementsController < Backend::BaseController
    manage_restfully

    def self.cvi_statements_conditions
      code = ''
      code = search_conditions(cvi_statements: %i[cvi_number declarant farm_name]) + " ||= []\n"
      code << "c\n "
      code.c
    end

    def self.cvi_cadastral_plants_conditions
      code = ''
      code << "c = ['1=1']\n"

      code << "unless params[:q].blank? \n"
      code << "  c[0] << \" AND (CONCAT(#{CviCadastralPlant.table_name}.section,#{CviCadastralPlant.table_name}.work_number,\'-\',#{CviCadastralPlant.table_name}.land_parcel_number) LIKE ? OR #{CviCadastralPlant.table_name}.commune LIKE ? OR #{CviCadastralPlant.table_name}.campaign LIKE ?) \"\n"
      code << "  c << param = '%'+ params[:q] + '%' \n"
      code << "  c << param \n"
      code << "  c << param \n"
      code << "end \n"

      code << "c[0] << ' AND #{CviCadastralPlant.table_name}.cvi_statement_id = ?'\n"
      code << "c << params[:id].to_i\n"

      # state
      code << "unless params[:state].blank? \n"
      code << "  c[0] << ' AND #{CviCadastralPlant.table_name}.state IN (?)'\n"
      code << "  c << params[:state]\n"
      code << "end\n"

      # area
      code << "if params[:area_value] \n"
      code << "  lower,higher = params[:area_value].split(',').map(&:to_f)\n"
      code << "  c[0] << ' AND #{CviCadastralPlant.table_name}.area_value BETWEEN ? AND ?'\n"
      code << "  c << lower\n"
      code << "  c << higher\n"
      code << "end\n"

      # designation_of_origin_name
      code << "unless params[:designation_of_origin_name].blank? \n"
      code << "  c[0] << ' AND #{RegistredProtectedDesignationOfOrigin.table_name}.geographic_area = ?'\n"
      code << "  c << params[:designation_of_origin_name]\n"
      code << "end\n"

      # vine_variety_name
      code << "unless params[:vine_variety_name].blank? \n"
      code << "  c[0] << ' AND #{MasterVineVariety.table_name}.specie_name = ?'\n"
      code << "  c << params[:vine_variety_name]\n"
      code << "end\n"

      # inter_row_distance
      code << "if params[:inter_row_distance_value] \n"
      code << "  lower,higher = params[:inter_row_distance_value].split(',').map(&:to_i)\n"
      code << "  c[0] << ' AND #{CviCadastralPlant.table_name}.inter_row_distance_value BETWEEN ? AND ?'\n"
      code << "  c << lower\n"
      code << "  c << higher\n"
      code << "end\n"

      # inter_vine_plant_distance
      code << "if params[:inter_vine_plant_distance_value]\n"
      code << "  lower,higher = params[:inter_row_distance_value].split(',').map(&:to_i)\n"
      code << "  c[0] << ' AND #{CviCadastralPlant.table_name}.inter_vine_plant_distance_value BETWEEN ? AND ?'\n"
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
      t.column :total_area, datatype: :measure, label_method: :total_area_formated
      t.column :state
    end

    list(:cvi_cadastral_plants, conditions: cvi_cadastral_plants_conditions, joins: %i[designation_of_origin vine_variety rootstock]) do |t|
      t.column :land_parcel_id
      t.action :edit, url: { format: :js, remote: true }
      t.action :destroy
      t.column :commune
      t.column :locality
      t.column :cadastral_reference
      t.column :designation_of_origin_name
      t.column :vine_variety_name
      t.column :area, datatype: :measure, label_method: :area_formated
      t.column :campaign
      t.column :rootstock_number
      t.column :inter_vine_plant_distance, datatype: :measure
      t.column :inter_row_distance, datatype: :measure
      t.column :state
    end

    list(:cvi_cadastral_plants_map, model: :cvi_cadastral_plants, conditions: cvi_cadastral_plants_conditions, joins: %i[designation_of_origin vine_variety rootstock]) do |t|
      t.column :land_parcel_id
      t.column :commune
      t.column :locality
      t.column :cadastral_reference, url: { controller: 'cvi_statements', action: 'show', id: 'params[:id]'.c}
      t.column :designation_of_origin_name
      t.column :vine_variety_name
      t.column :area, datatype: :measure, label_method: :area_formated
      t.column :campaign
      t.column :rootstock_number
      t.column :inter_vine_plant_distance, datatype: :measure
      t.column :inter_row_distance, datatype: :measure
      t.column :state
    end
  end
end
