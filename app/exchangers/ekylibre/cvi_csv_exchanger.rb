require 'csv'

HEADER_CONVERSION = {
  'CVI_ID' => :cvi_number,
  'Date extraction' => :extraction_date,
  'N° SIRET' => :siret_number,
  'Nom Exploitation' => :farm_name,
  'Nom Gestionnaire' => :declarant,
  'Commune' => :commune,
  'Lieu-dit' => :locality,
  'Code INSEE' => :insee_number,
  'feuille' => :sheet,
  'numéro' => :plot_number,
  'Sous Parcelle' => :sub_plot_number,
  'Produit Vin' => :product,
  'Cepage' => :grape_variety,
  'superficie (ha)' => :ha_area,
  'superficie  (ar)' => :ar_area,
  'superficie  (ca)' => :ca_area,
  'Campagne de plantation' => :campaign,
  'Porte-greffe_Code_Douane' => :rootstock,
  'Ecart pied (cm)' => :inter_vine_plant_distance,
  'Ecart rang (cm)' => :inter_row_distance,
  'Etat' => :state,
  'Mode faire valoir' => :type_of_occupancy,
  'Date Modification foncière' => :property_assessment_change
}.freeze

STATES = {
  'PLANTÉES' => :planted,
  'Arrachées avec autorisation' => :removed_with_authorization
}.freeze

CVI_STATEMENT_KEYS = %i[cvi_number extraction_date siret_number farm_name declarant total_area].freeze
CVI_CADASTRAL_PLANT_KEYS = %i[commune locality insee_number area product grape_variety cadastral_reference campaign rootstock inter_row_distance inter_vine_plant_distance state].freeze

module Ekylibre
  class CviCsvExchanger < ActiveExchanger::Base
    def check
      raise 'wrong file extension' if File.extname(file) != '.csv'

      CSV.foreach(file, headers: true, header_converters: ->(h) { HEADER_CONVERSION[h] || (raise "Unknown column name #{h}") }) do |row|
        raise "Unknow state #{row[:state]}" unless STATES[row[:state]]
      end
      true
    end

    def import
      w.count = CSV.read(file).count - 1

      CSV.foreach(file, headers: true, header_converters: ->(h) { HEADER_CONVERSION[h] || (raise "Unknown column name #{h}") }) do |row|
        begin
          convert_types(row)
          calculate_total_area(row)
          concat_cadastral_reference(row)
          convert_states(row)
          import_cvi_statements(row)
          import_cvi_cadastral_plants(row)
        rescue StandardError => e
          raise e 
        end
        w.check_point
      end
    end

    private

    def import_cvi_cadastral_plants(row)
      cvi_statement = CviStatement.find_by(cvi_number: row[:cvi_number])
      CviCadastralPlant.create!(
        row.to_h.select { |key, _| CVI_CADASTRAL_PLANT_KEYS.include? key }.merge(cvi_statement_id: cvi_statement.id)
      )
    end

    def import_cvi_statements(row)
      cvi_statement = CviStatement.find_by(cvi_number: row[:cvi_number])
      if cvi_statement
        total_area = cvi_statement.total_area + row[:area]
        cadastral_sub_plant_count = cvi_statement.cadastral_sub_plant_count + 1
        cadastral_plant_count = if !row[:sub_plot_number] || row[:sub_plot_number] == '1'
                                  cvi_statement.cadastral_plant_count + 1
                                else
                                  cvi_statement.cadastral_plant_count
                                end
        cvi_statement.update(cadastral_sub_plant_count: cadastral_sub_plant_count, cadastral_plant_count: cadastral_plant_count, total_area: total_area)
      else
        CviStatement.create!(
          row.to_h.select { |key, _| CVI_STATEMENT_KEYS.include? key }.merge(cadastral_sub_plant_count: 1, cadastral_plant_count: 1)
        )
      end
    end

    def convert_types(row)
      %i[extraction_date property_assessment_change].each do |header|
        row[header] = Date.parse(row[header]) if row[header]
      end

      %i[ha_area ar_area ca_area inter_vine_plant_distance inter_row_distance].each do |header|
        row[header] = row[header].to_i if row[header]
      end
    end

    def convert_states(row)
      row[:state] = STATES[row[:state]]
    end

    def concat_cadastral_reference(row)
      row << if row[:sub_plot_number]
               [:cadastral_reference, "#{row[:plot_number].rjust(4, '0')}-#{row[:sub_plot_number]}"]
             else
               [:cadastral_reference, row[:plot_number].rjust(4, '0')]
             end
    end

    def calculate_total_area(row)
      total_area = row[:ha_area] + 0.01 * row[:ar_area] + 0.0001 * row[:ca_area]
      row << [:total_area, total_area]
      row << [:area, total_area]
      %i[ha_area ar_area ca_area].each do |header|
        row.delete(header)
      end
    end
  end
end
