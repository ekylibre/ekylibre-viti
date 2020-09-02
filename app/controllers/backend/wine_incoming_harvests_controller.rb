module Backend
  class WineIncomingHarvestsController < Backend::BaseController
    manage_restfully

    def self.wine_incoming_harvests_conditions
      code = search_conditions(wine_incoming_harvests: %i[number ticket_number description]) + " ||= []\n"
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
      code << "c\n"
      code.c
    end

    list(conditions: wine_incoming_harvests_conditions) do |t|
      t.action :edit
      t.action :destroy
      t.column :number, url: true
      t.column :ticket_number
      t.column :received_at
      t.column :quantity_value, on_select: :sum, value_method: :quantity, datatype: :bigdecimal
      t.column :quantity_unit, label_method: :human_quantity_unit_name
    end

    list(:plants, model: :wine_incoming_harvest_plant, joins: :plant, conditions: { wine_incoming_harvest_id: 'params[:id]'.c }) do |t|
      t.column :plant, url: true
      t.column :net_surface_area, through: :plant, label: :total_area_in_hectare, datatype: :measure, class: 'center'
      t.column :harvest_percentage_received, label_method: :displayed_harvest_percentage, class: 'center'
      t.column :net_harvest_area, datatype: :measure, class: 'center'
    end

    list(:storages, model: :wine_incoming_harvest_storage, conditions: { wine_incoming_harvest_id: 'params[:id]'.c }) do |t|
      t.column :storage, url: true
      t.column :quantity, label: :volume_in_winery, datatype: :measure, class: 'center'
    end
  end
end
