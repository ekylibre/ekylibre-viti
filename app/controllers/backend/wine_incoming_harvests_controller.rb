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

      # Current campaign
      code << "if current_campaign\n"
      code << "  c[0] << \" AND EXTRACT(YEAR FROM #{WineIncomingHarvest.table_name}.received_at) = ?\"\n"
      code << "  c << current_campaign.harvest_year\n"
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
      t.column :quantity_unit
      t.column :human_storages_names
      t.column :tavp, class: 'center'
      t.column :human_species_variesties_names
    end

    list(:plants, model: :wine_incoming_harvest_plant, joins: :plant, conditions: { wine_incoming_harvest_id: 'params[:id]'.c }, order: 'products.name ASC') do |t|
      t.column :plant, url: true
      t.column :net_surface_area_plant, label: :total_area_in_hectare, datatype: :measure, class: 'center'
      t.column :harvest_percentage_received, label_method: :displayed_harvest_percentage, class: 'center'
      t.column :net_harvest_area, label_method: :displayed_net_harvest_area, class: 'center'
      t.column :harvest_quantity, class: 'center'
      t.column :quantity_unit, class: 'center'
      t.column :rows_harvested, class: 'center'
      t.column :plant_specie_variety_name, class: 'center'
    end

    list(:storages, model: :wine_incoming_harvest_storage, conditions: { wine_incoming_harvest_id: 'params[:id]'.c }) do |t|
      t.column :storage, url: true
      t.column :quantity, label: :volume_in_winery, datatype: :measure, class: 'center'
    end

    list(:presses, model: :wine_incoming_harvest_press, conditions: { wine_incoming_harvest_id: 'params[:id]'.c }) do |t|
      t.column :press, url: true
      t.column :quantity_value, label: :volume_in_winery, datatype: :measure, class: 'center'
      t.column :pressing_schedule
      t.column :pressing_started_at, label_method: :decorated_pressing_started_at
    end

    def index
      respond_to do |format|
        format.html do
        end
        format.odt do
          filename = "Reception_de_vendange"
          @dataset_wine_incoming_harvest = wine_incoming_harvest_data
          send_data to_odt(@dataset_wine_incoming_harvest, filename, params).generate, type: 'application/vnd.oasis.opendocument.text', disposition: 'attachment', filename: filename << '.odt'
        end
        format.pdf do
          to_pdf
        end
      end
    end

    protected

    def wine_incoming_harvest_data
      report = HashWithIndifferentAccess.new
      report[:items] = []
      WineIncomingHarvest.where(campaign: current_campaign).map{|v|report[:items] << v.wine_incoming_harvest_reporting}
      report
    end

    def to_pdf
      filename = "#{:wine_incoming_harvest.tl} #{current_campaign.name}"
      key = "#{filename}-#{Time.zone.now.l(format: '%Y-%m-%d-%H:%M:%S')}"
      @dataset_wine_incoming_harvest = wine_incoming_harvest_data
      file_odt = to_odt(@dataset_wine_incoming_harvest, filename, params).generate
      tmp_dir = Ekylibre::Tenant.private_directory.join('tmp')
      uuid = SecureRandom.uuid
      source = tmp_dir.join(uuid + '.odt')
      dest = tmp_dir.join(uuid + '.pdf')
      FileUtils.mkdir_p tmp_dir
      File.write source, file_odt
      `soffice  --headless --convert-to pdf --outdir #{Shellwords.escape(tmp_dir.to_s)} #{Shellwords.escape(source)}`
      Document.create!(
                 nature: 'wine_incoming_harvest_register',
                 key: key,
                 name: filename,
                 file: File.open(dest),
                 file_file_name: "#{key}.pdf"
               )
      send_data(File.read(dest), type: 'application/pdf', disposition: 'attachment', filename: filename + '.pdf')
    end

    def to_odt(order_reporting, filename, _params)
      # TODO: add a generic template system path
      language = current_user.language
      report = ODFReport::Report.new(EkylibreEkyviti::Engine.root.join('config', 'locales', language, 'reporting', 'wine_incoming_harvest.odt')) do |r|
        # TODO: add a helper with generic metod to implemend header and footer
        e = Entity.of_company
        company_address = e.default_mail_address.present? ? e.default_mail_address.coordinate : '-'
        r.add_field 'COMPANY_ADDRESS', company_address
        r.add_field 'CURRENT_CAMPAIGN', "#{:campaign.tl} #{current_campaign.name}"
        r.add_field 'PRINTED_AT', Time.zone.now.l(format: '%d/%m/%Y %T')

        r.add_table('W_ITEMS', order_reporting[:items], header: true) do |t|
          t.add_column(:wine_harvest_number)
          t.add_column(:wine_harvest_ticket_number)
          t.add_column(:wine_harvest_received_at)
          t.add_column(:wine_harvest_plants_name)
          t.add_column(:wine_net_harvest_area)
          t.add_column(:quantity_value)
          t.add_column(:quantity_unit)
          t.add_column(:wine_harvest_storages_name)
          t.add_column(:wine_harvest_tavp)
          t.add_column(:wine_harvest_species_name)
        end
      end
    end

  end
end
