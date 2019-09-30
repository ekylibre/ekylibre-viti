module Ekylibre
  class CviCsvExchanger < CviExchanger
    def check
      file_extension = File.extname(file)
      raise I18n.translate('exchangers.ekylibre_cvi.errors.wrong_file_extension', file_extension: file_extension, required_file_extension: '.csv') if file_extension != '.csv'

      CSV.foreach(file, headers: true, header_converters: ->(h) { HEADER_CONVERSION[h] || (raise I18n.translate('exchangers.ekylibre_cvi.errors.unknown_column_name', column_name: h)) }) do |row|
        raise I18n.translate('exchangers.ekylibre_cvi.errors.unknown_state', state: row[:state]) unless STATES[row[:state]]
        raise I18n.translate('exchangers.ekylibre_cvi.errors.invalid_siret', value: row[:siret_number]) unless Luhn.valid?(row[:siret_number])
      end
      true
    end

    def import
      w.count = CSV.read(file).count - 1
      ActiveRecord::Base.transaction do
        CSV.foreach(file, headers: true, header_converters: ->(h) { HEADER_CONVERSION[h] || (raise "Unknown column name #{h}") }) do |row|
          begin
            convert_types(row)
            calculate_total_area(row)
            format_insee_code(row)
            format_work_number(row)
            convert_states(row)
            import_cvi_statements(row)
            import_cvi_cadastral_plants(row)
          rescue StandardError => e
            raise e
          end
          w.check_point
        end
      end
    end

    private

    def import_cvi_cadastral_plants(row)
      cvi_statement = CviStatement.find_by(cvi_number: row[:cvi_number])

      designation_of_origin = RegistredProtectedDesignationOfOrigin.find_by(geographic_area: row[:product])
      unless designation_of_origin
        message = I18n.translate('exchangers.ekylibre_cvi.errors.unknown_designation_of_origin', value: row[:product])
        w.error message
        raise message
      end

      vine_variety = MasterVineVariety.find_by(specie_name: row[:grape_variety], category_name: 'Cépage')
      unless vine_variety
        message = I18n.translate('exchangers.ekylibre_cvi.errors.unknown_vine_variety', value: row[:grape_variety])
        w.error message
        raise message
      end

      rootstock = MasterVineVariety.find_by(customs_code: row[:rootstock], category_name: 'Porte-greffe')
      unless rootstock
        message = I18n.translate('exchangers.ekylibre_cvi.errors.unknown_rootstock', value: row[:rootstock])
        w.error message
        raise message
      end

      insee_number = "#{row[:insee_number]}%"
      work_number = row[:work_number]
      section = row[:section]

      cadastral_land_parcel_zone = CadastralLandParcelZone.where('id LIKE ? and section = ? and work_number =?', insee_number, section, work_number).first
      unless cadastral_land_parcel_zone
        message = I18n.translate('exchangers.ekylibre_cvi.errors.unknown_cadastral_land_parcel', value: insee_number + section + work_number)
        w.error message
        raise message
      end

      CviCadastralPlant.create!(
        row.to_h.select { |key, _| CVI_CADASTRAL_PLANT_KEYS.include? key }
          .merge(cvi_statement_id: cvi_statement.id, land_parcel_id: cadastral_land_parcel_zone.id, designation_of_origin_id: designation_of_origin.id, vine_variety_id: vine_variety.id, rootstock_id: rootstock.id, area: row[:area])
      )
    end

    def import_cvi_statements(row)
      cvi_statement = CviStatement.find_by(cvi_number: row[:cvi_number])
      return CviStatement.create!(
        row.to_h
          .select { |key, _| CVI_STATEMENT_KEYS.include? key }
          .merge(cadastral_sub_plant_count: 1, cadastral_plant_count: 1, total_area: row[:area])
      ) unless cvi_statement
      total_area = cvi_statement.total_area + row[:area]
      cadastral_sub_plant_count = cvi_statement.cadastral_sub_plant_count + 1
      cadastral_plant_count = if row[:land_parcel_number].blank? || row[:land_parcel_number] == '1'
                                cvi_statement.cadastral_plant_count + 1
                              else
                                cvi_statement.cadastral_plant_count
                              end
      cvi_statement.update!(cadastral_sub_plant_count: cadastral_sub_plant_count, cadastral_plant_count: cadastral_plant_count, total_area: total_area)
    end

    def convert_types(row)
      %i[extraction_date property_assessment_change].each do |header|
        row[header] = Date.soft_parse(row[header]) if row[header]
      end

      %i[inter_vine_plant_distance inter_row_distance].each do |header|
        row[header] = Measure.new(row[header].to_i, :centimeter) if row[header]
      end

      %i[ha_area ar_area ca_area].each do |header|
        row[header] = row[header].to_i if row[header]
      end
    end

    def format_insee_code(row)
      insee_number = row[:insee_number].to_s
      insee_number.slice!(2)
      row[:insee_number] = insee_number
    end

    def format_work_number(row)
      row[:work_number] = row[:work_number].to_s.sub!(/^0*/, '')
    end

    def convert_states(row)
      row[:state] = STATES[row[:state]]
    end

    def calculate_total_area(row)
      total_area = row[:ha_area] + 0.01 * row[:ar_area] + 0.0001 * row[:ca_area]
      area = Measure.new(total_area, :hectare)
      row << [:area, area]
    end
  end
end
