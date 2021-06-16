module Ekylibre
  module CviComputation
    HEADER_CONVERSION = {
      'CVI_ID' => :cvi_number,
      'Date_Extraction' => :extraction_date,
      'N_SIRET' => :siret_number,
      'Nom_Exploitation' => :farm_name,
      'Nom_Gestionnaire' => :declarant,
      'Commune' => :commune,
      'Lieu-dit' => :locality,
      'Code_INSEE' => :insee_number,
      'Feuille' => :section,
      'Reference_Parcelle' => :work_number,
      'Sous_Parcelle' => :land_parcel_number,
      'Produit_Vin' => :product,
      'Cepage' => :grape_variety,
      'Superficie_ha' => :ha_area,
      'Superficie_ar' => :ar_area,
      'Superficie_ca' => :ca_area,
      'Campagne_Plantation' => :planting_campaign,
      'rootstock_Code_Douane' => :rootstock,
      'Ecart_Pied' => :inter_vine_plant_distance,
      'Ecart_Rang' => :inter_row_distance,
      'Etat' => :state,
      'Mode_Faire_Valoir' => :type_of_occupancy,
      'Date_Modification_Fonciere' => :land_modification_date
    }.freeze

    STATES = {
      'Plantées' => :planted,
      'Arrachées avec autorisation' => :removed_with_authorization
    }.freeze

    TYPE_OF_OCCUPANCY = {
      'Fermage' => :tenant_farming,
      'Propriétaire' => :owner
    }.freeze

    CVI_STATEMENT_KEYS = %i[cvi_number extraction_date siret_number farm_name declarant].freeze
    CVI_CADASTRAL_PLANT_KEYS = %i[section work_number planting_campaign inter_row_distance inter_vine_plant_distance state type_of_occupancy land_modification_date].freeze

    def import
      w.count = cvi_row_list.length
      ActiveRecord::Base.transaction do
        cvi_row_list.each do |h_cvi_statement|
          begin
            convert_types(h_cvi_statement)
            calculate_total_area(h_cvi_statement)
            format_insee_code(h_cvi_statement)
            format_work_number(h_cvi_statement)
            format_planting_campaign(h_cvi_statement)
            convert_states(h_cvi_statement)
            convert_type_of_occupancy(h_cvi_statement)
            import_cvi_statements(h_cvi_statement)
            import_cvi_cadastral_plants(h_cvi_statement)
          rescue StandardError => e
            raise e
          end
          w.check_point
        end
      end
    end

    private

    attr_accessor :cvi_row_list

    def import_cvi_cadastral_plants(h_cvi_statement)
      cvi_statement = CviStatement.find_by(cvi_number: h_cvi_statement[:cvi_number])
      product_name = h_cvi_statement[:product].to_s.lower
      designation_of_origins = RegisteredProtectedDesignationOfOrigin.where("unaccent(product_human_name_fra) ILIKE unaccent(?)", "%#{product_name}%")

      designation_of_origin = if product_name == ""
                                nil
                              elsif designation_of_origins.length > 1
                                designation_of_origins.min_by do |doo|
                                  (doo.product_human_name_fra.length - product_name.length).abs
                                end
                              else
                                designation_of_origins.first
                              end

      vine_variety = RegisteredVineVariety.find_by(short_name: h_cvi_statement[:grape_variety], category_name: ['variety', 'hybrid'])
      unless vine_variety
        message = :unknown_vine_variety.tl(value: h_cvi_statement[:grape_variety])
        w.error message
        raise message
      end

      registered_postal_zone = RegisteredPostalZone.find_by(code: h_cvi_statement[:insee_number])
      unless registered_postal_zone
        message = :unknown_insee_number.tl(value: h_cvi_statement[:insee_number])
        w.error message
        raise message
      end

      unless h_cvi_statement[:rootstock].blank? || h_cvi_statement[:rootstock] == 'NC99'
        rootstock = RegisteredVineVariety.find_by(custom_code: h_cvi_statement[:rootstock], category_name: 'rootstock')
        unless rootstock
          message = :unknown_rootstock.tl(value: h_cvi_statement[:rootstock])
          w.error message
          raise message
        end
      end

      insee_number = "#{h_cvi_statement[:insee_number]}%"
      work_number = h_cvi_statement[:work_number]
      section = h_cvi_statement[:section]

      cadastral_land_parcel_zone = CadastralLandParcelZone.where('id LIKE ? and section = ? and work_number =?', insee_number, section, work_number).first
      CviCadastralPlant.create!(
        h_cvi_statement.to_h.select { |key, _| CVI_CADASTRAL_PLANT_KEYS.include? key }
          .merge(cvi_statement_id: cvi_statement.id,
                 land_parcel_id: cadastral_land_parcel_zone.try('id'),
                 designation_of_origin_id: designation_of_origin.try('id'),
                 land_parcel_number: h_cvi_statement[:land_parcel_number] && h_cvi_statement[:land_parcel_number].rjust(2, "0"),
                 vine_variety_id: vine_variety.id,
                 rootstock_id: rootstock.try('id'),
                 area: h_cvi_statement[:area],
                 location: Location.create(registered_postal_zone_id: registered_postal_zone.id, locality: h_cvi_statement[:locality]))
      )
    end

    def import_cvi_statements(h_cvi_statement)
      cvi_statement = CviStatement.find_by(cvi_number: h_cvi_statement[:cvi_number])
      unless cvi_statement
        return CviStatement.create!(
          h_cvi_statement.to_h
            .select { |key, _| CVI_STATEMENT_KEYS.include? key }
            .merge(cadastral_sub_plant_count: 1, cadastral_plant_count: 1, total_area: h_cvi_statement[:area])
        )
      end
      total_area = cvi_statement.total_area
      total_area += h_cvi_statement[:area] if h_cvi_statement[:state] == :planted
      cadastral_sub_plant_count = cvi_statement.cadastral_sub_plant_count + 1
      cadastral_plant_count = if h_cvi_statement[:land_parcel_number].blank? || h_cvi_statement[:land_parcel_number].to_s == '1'
                                cvi_statement.cadastral_plant_count + 1
                              else
                                cvi_statement.cadastral_plant_count
                              end
      cvi_statement.update!(cadastral_sub_plant_count: cadastral_sub_plant_count, cadastral_plant_count: cadastral_plant_count, total_area: total_area)
    end

    def convert_types(h_cvi_statement)
      %i[extraction_date land_modification_date].each do |key|
        h_cvi_statement[key] = Date.parse(h_cvi_statement[key]) if h_cvi_statement[key].present?
      end

      %i[inter_vine_plant_distance inter_row_distance].each do |header|
        h_cvi_statement[header] = Measure.new(h_cvi_statement[header].to_i, :centimeter) if h_cvi_statement[header]
      end

      %i[ha_area ar_area ca_area].each do |key|
        h_cvi_statement[key] = if h_cvi_statement[key]
                                 h_cvi_statement[key].to_i
                               else
                                 0
                               end
      end
    end

    def format_insee_code(h_cvi_statement)
      insee_number = h_cvi_statement[:insee_number].to_s
      insee_number.slice!(2)
      h_cvi_statement[:insee_number] = insee_number
    end

    def format_work_number(h_cvi_statement)
      h_cvi_statement[:work_number] = h_cvi_statement[:work_number].to_s.sub!(/^0*/, '')
    end

    def format_planting_campaign(h_cvi_statement)
      return if h_cvi_statement[:planting_campaign].to_s != "9999" || h_cvi_statement[:planting_campaign].to_s != ''

      h_cvi_statement[:planting_campaign] = nil
    end

    def convert_states(h_cvi_statement)
      h_cvi_statement[:state] = STATES[h_cvi_statement[:state]]
    end

    def convert_type_of_occupancy(h_cvi_statement)
      h_cvi_statement[:type_of_occupancy] = TYPE_OF_OCCUPANCY[h_cvi_statement[:type_of_occupancy]]
    end

    def calculate_total_area(h_cvi_statement)
      total_area = h_cvi_statement[:ha_area] + 0.01 * h_cvi_statement[:ar_area] + 0.0001 * h_cvi_statement[:ca_area]
      area = Measure.new(total_area, :hectare)
      h_cvi_statement[:area] = area
    end

    def cvi_statement_already_exist?
      cvi_statement_ids = cvi_row_list.collect { |e| e[:cvi_number].to_s }.uniq
      cvi_statements_imported_ids = CviStatement.all.pluck(:cvi_number)
      (cvi_statements_imported_ids & cvi_statement_ids).any?
    end
  end
end
