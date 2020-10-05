module Backend
  class WineIncomingHarvestsController < Backend::BaseController
    manage_restfully

    def self.wine_incoming_harvests_conditions
      code = search_conditions(wine_incoming_harvests: %i[number ticket_number description designation_of_origin_name wine_storage_names plant_name tavp]) + " ||= []\n"
      code << "if params[:period].present? && params[:period].to_s != 'all'\n"
      code << "  c[0] << ' AND #{WineIncomingHarvest.table_name}.received_at BETWEEN ? AND ?'\n"
      code << "  if params[:period].to_s == 'interval'\n"
      code << "    c << params[:started_on]\n"
      code << "    c << params[:stopped_on]\n"
      code << "  else\n"
      code << "    interval = params[:period].to_s.split('_')\n"
      code << "    c << interval.first\n"
      code << "    c << interval.second\n"
      code << "  end\n"
      code << "end\n"

      # # designation_of_origin_name CEPAGE
      code << "unless params[:designation_of_origin_name].blank? \n"
      code << "  c[0] << ' AND #{WineIncomingHarvest.table_name}.id IN (SELECT wine_incoming_harvest_id FROM #{WineIncomingHarvestPlant.table_name} WHERE plant_id IN (SELECT id FROM #{Plant.table_name} WHERE specie_variety->>\\'specie_variety_name\\' = ?))'\n"
      code << "  c << params[:designation_of_origin_name]\n"
      code << "end\n"

      # # wine_storage_name CUVE
      code << "unless params[:wine_storage_name].blank? \n"
      code << "  c[0] << ' AND #{WineIncomingHarvest.table_name}.id IN (SELECT wine_incoming_harvest_id FROM #{WineIncomingHarvestStorage.table_name} WHERE storage_id IN (SELECT id FROM #{Equipment.table_name} WHERE name = ?))'\n"
      code << "  c << params[:wine_storage_name]\n"
      code << "end\n"

      # plant_name CULTURE
      code << "unless params[:plant_name].blank? \n"
      code << "  c[0] << ' AND #{WineIncomingHarvest.table_name}.id IN (SELECT wine_incoming_harvest_id FROM #{WineIncomingHarvestPlant.table_name} WHERE plant_id IN (SELECT id FROM #{Plant.table_name} WHERE name = ?))'\n"
      code << "  c << params[:plant_name]\n"
      code << "end\n"

      # tavp
      code << "if params[:tavp] \n"
      code << "  lower,higher = params[:tavp].split(',').map(&:to_f)\n"
      code << "  c[0] << ' AND #{WineIncomingHarvest.table_name}.analysis_id IN (SELECT id FROM #{Analysis.table_name} WHERE id IN (SELECT analysis_id FROM #{AnalysisItem.table_name} WHERE indicator_name = \\'estimated_harvest_alcoholic_volumetric_concentration\\' AND absolute_measure_value_value BETWEEN ? AND ?))'\n"
      code << "  c << lower\n"
      code << "  c << higher\n"
      code << "end\n"

      code << "c\n"
      code.c
    end

    list(conditions: wine_incoming_harvests_conditions) do |t|
      t.action :edit
      t.action :destroy
      t.column :number, url: true
      t.column :ticket_number
      t.column :received_at
      t.column :human_plants_names
      t.column :net_harvest_areas_sum
      t.column :quantity_value, on_select: :sum, value_method: :quantity, datatype: :bigdecimal
      t.column :quantity_unit, label_method: :human_quantity_unit_name
      t.column :human_storages_names
      t.column :tavp
      t.column :human_species_variesties_names
    end

    list(:plants, model: :wine_incoming_harvest_plant, joins: :plant, conditions: { wine_incoming_harvest_id: 'params[:id]'.c }) do |t|
      t.column :plant, url: true
      t.column :net_surface_area, through: :plant, label: :total_area_in_hectare, datatype: :measure, class: 'center'
      t.column :harvest_percentage_received, label_method: :displayed_harvest_percentage, class: 'center'
      t.column :net_harvest_area, datatype: :measure, class: 'center'
      t.column :harvest_quantity, class: 'center'
      t.column :rows_harvested, label_method: :displayed_rows_harvested, class: 'center'
      t.column :plant_specie_name, class: 'center'
    end

    list(:storages, model: :wine_incoming_harvest_storage, conditions: { wine_incoming_harvest_id: 'params[:id]'.c }) do |t|
      t.column :storage, url: true
      t.column :quantity, label: :volume_in_winery, datatype: :measure, class: 'center'
    end
  end
end
