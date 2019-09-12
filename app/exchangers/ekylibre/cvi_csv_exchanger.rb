require 'csv'

HEADER_CONVERSION = {
  'CVI_ID' => :cvi_id,
  'Date extraction' => :extraction_date,
  'N° SIRET' => :siret_id,
  'Nom Exploitation' => :farm,
  'Nom Gestionnaire' => :manager_name,
  'Commune' => :municipality,
  'Lieu-dit' => :locality,
  'Code INSEE' => :insee_code,
  'feuille' => :sheet,
  'numéro' => :number,
  'Sous Parcelle' => :plot,
  'Produit Vin' => :wine_product,
  'Cepage' => :grape_variety,
  'superficie (ha)' => :ha_area,
  'superficie  (ar)' => :ar_area,
  'superficie  (ca)' => :ca_area,
  'Campagne de plantation' => :plant_campaign,
  'Porte-greffe_Code_Douane' => :rootstock,
  'Ecart pied (cm)' => :inter_vine_plant_distance,
  'Ecart rang (cm)' => :inter_row_distance,
  'Etat' => :state,
  'Mode faire valoir' => :type_of_occupancy,
  'Date Modification foncière' => :property_assessment_change
}.freeze

STATES = { 
  "PLANTEES"=> "planted",
  "ARR. AVEC AUTORISATION"=> "removed with authorization",
}.freeze

module Ekylibre
  class CviCsvExchanger < ActiveExchanger::Base
    
    def check
      CSV.foreach(file, headers: true, header_converters: ->(h) { if HEADER_CONVERSION[h]; HEADER_CONVERSION[h] else raise "Unknown column name #{h}" end }) do |row|
        unless STATES[row[:state]]
          raise "Unknow state #{state}"
        end
      end
    end

    def import
      CSV.foreach(file, headers: true, header_converters: ->(h) { if HEADER_CONVERSION[h]; HEADER_CONVERSION[h] else raise "Unknown column name #{h}" end }) do |row|
        convert_types(row)
        calculate_total_area(row)
        convert_states(row)
        (@cvi_list ||= []) << row.to_h
      end
      p @cvi_list
    end

    private

    attr_reader :csv_file_path

    def convert_types(row)
      %i[extraction_date property_assessment_change].each do |header|
        row[header] = Date.parse(row[header]) if row[header]
      end

      %i[ha_area ar_area ca_area inter_vine_plant_distance inter_row_distance].each do |header|
        row[header] = row[header].to_i
      end
    end

    def convert_states(row)
      row[:state] = STATES[row[:state]]
    end 

    def calculate_total_area(row)
      total_area = 100 * row[:ha_area] + row[:ar_area] + 0.01 * row[:ca_area]
      row << [:area, total_area]
      %i[ha_area ar_area ca_area].each do |header|
        row.delete(header)
      end
    end
  end
end
