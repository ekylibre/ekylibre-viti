module Ekylibre
  class CviJsonExchanger < CviExchanger
    def check
      file_extension = File.extname(file)
      raise ::I18n.translate('exchangers.ekylibre_cvi.errors.wrong_file_extension', file_extension: file_extension, required_file_extension: '.json') if file_extension != '.json'

      data = JSON.parse(File.read(file))
      data.map do |cvi|
        cvi.each_key do |key|
          raise ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_column_name', column_name: key) unless HEADER_CONVERSION[key]
        end
        raise ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_state', state: cvi['Etat']) unless STATES[cvi['Etat']]
        raise ::I18n.translate('exchangers.ekylibre_cvi.errors.invalid_siret', value: cvi['N° SIRET']) unless Luhn.valid?(cvi['N° SIRET'])
      end
      true
    end

    def import
      data = JSON.parse(File.read(file))
      w.count = data.length
      ActiveRecord::Base.transaction do
        data.each do |h_cvi_statement|
          begin
            convert_keys(h_cvi_statement)
            convert_types(h_cvi_statement)
            calculate_total_area(h_cvi_statement)
            format_insee_code(h_cvi_statement)
            format_work_number(h_cvi_statement)
            convert_states(h_cvi_statement)
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

    def convert_keys(h_cvi_statement)
      h_cvi_statement.transform_keys! { |old_key| HEADER_CONVERSION[old_key] }
    end

    def import_cvi_cadastral_plants(h_cvi_statement)
      cvi_statement = CviStatement.find_by(cvi_number: h_cvi_statement[:cvi_number])

      designation_of_origin = RegistredProtectedDesignationOfOrigin.find_by(geographic_area: h_cvi_statement[:product])
      unless designation_of_origin
        message = ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_designation_of_origin', value: h_cvi_statement[:product])
        w.error message
        raise message
      end

      vine_variety = MasterVineVariety.find_by(specie_name: h_cvi_statement[:grape_variety], category_name: 'Cépage')
      unless vine_variety
        message = ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_vine_variety', value: h_cvi_statement[:grape_variety])
        w.error message
        raise message
      end

      rootstock = MasterVineVariety.find_by(customs_code: h_cvi_statement[:rootstock], category_name: 'Porte-greffe')
      unless rootstock
        message = ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_rootstock', value: h_cvi_statement[:rootstock])
        w.error message
        raise message
      end

      insee_number = "#{h_cvi_statement[:insee_number]}%"
      work_number = h_cvi_statement[:work_number]
      section = h_cvi_statement[:section]

      cadastral_land_parcel_zone = CadastralLandParcelZone.where('id LIKE ? and section = ? and work_number =?', insee_number, section, work_number).first

      CviCadastralPlant.create!(
        h_cvi_statement.to_h.select { |key, _| CVI_CADASTRAL_PLANT_KEYS.include? key }
          .merge(cvi_statement_id: cvi_statement.id, land_parcel_id: cadastral_land_parcel_zone.try('id'), designation_of_origin_id: designation_of_origin.id, vine_variety_id: vine_variety.id, rootstock_id: rootstock.id, area: h_cvi_statement[:area])
      )
    end

    def import_cvi_statements(h_cvi_statement)
      cvi_statement = CviStatement.find_by(cvi_number: h_cvi_statement[:cvi_number])
      return  CviStatement.create!(
        h_cvi_statement.to_h
          .select { |key, _| CVI_STATEMENT_KEYS.include? key }
          .merge(cadastral_sub_plant_count: 1, cadastral_plant_count: 1, total_area: h_cvi_statement[:area])
      ) unless cvi_statement
      total_area = cvi_statement.total_area + h_cvi_statement[:area]
      cadastral_sub_plant_count = cvi_statement.cadastral_sub_plant_count + 1
      cadastral_plant_count = if h_cvi_statement[:land_parcel_number].blank? || h_cvi_statement[:land_parcel_number].to_s == '1'
                                cvi_statement.cadastral_plant_count + 1
                              else
                                cvi_statement.cadastral_plant_count
                              end
      cvi_statement.update!(cadastral_sub_plant_count: cadastral_sub_plant_count, cadastral_plant_count: cadastral_plant_count, total_area: total_area)
    end

    def convert_types(h_cvi_statement)
      %i[extraction_date property_assessment_change].each do |key|
        h_cvi_statement[key] = Date.soft_parse(h_cvi_statement[key]) unless h_cvi_statement[key].empty?
      end

      %i[inter_vine_plant_distance inter_row_distance].each do |header|
        h_cvi_statement[header] = Measure.new(h_cvi_statement[header].to_i, :centimeter) if h_cvi_statement[header]
      end

      %i[ha_area ar_area ca_area].each do |key|
        h_cvi_statement[key] = h_cvi_statement[key].to_i if h_cvi_statement[key]
      end
    end

    def format_insee_code(h_cvi_statement)
      insee_number = h_cvi_statement[:insee_number].to_s
      insee_number.slice!(2)
      h_cvi_statement[:insee_number] = insee_number
    end

    def format_work_number(h_cvi_statement)
      h_cvi_statement[:work_number] = h_cvi_statement[:work_number].to_s.sub!(/^0*/, "")
    end

    def convert_states(h_cvi_statement)
      h_cvi_statement[:state] = STATES[h_cvi_statement[:state]]
    end

    def calculate_total_area(h_cvi_statement)
      total_area = h_cvi_statement[:ha_area] + 0.01* h_cvi_statement[:ar_area] + 0.0001 * h_cvi_statement[:ca_area]
      area = Measure.new(total_area, :hectare)
      h_cvi_statement[:area] = area
    end
  end
end