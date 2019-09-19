require 'json'

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
  'Ecart rang (cm)' => :inter_h_cvi_statement_distance,
  'Etat' => :state,
  'Mode faire valoir' => :type_of_occupancy,
  'Date Modification foncière' => :property_assessment_change
}.freeze

STATES = {
  'PLANTÉES' => :planted,
  'Arrachées avec autorisation' => :removed_with_authorization
}.freeze

CVI_STATEMENT_KEYS = %i[cvi_number extraction_date siret_number farm_name declarant total_area].freeze
CVI_CADASTRAL_PLANT_KEYS = %i[commune locality insee_number area product grape_variety cadastral_reference campaign rootstock inter_h_cvi_statement_distance inter_vine_plant_distance state].freeze

module Ekylibre
  class CviJsonExchanger < ActiveExchanger::Base
    def check
      raise 'wrong file extension' if File.extname(file) != '.json'
      data = JSON.parse(File.read(file))
      data.map do |cvi| 
        cvi.each_key do |key| 
          raise "Unknown column name #{key}" unless HEADER_CONVERSION[key] 
        end
        raise "Unknow state #{cvi["Etat"]}" unless STATES[cvi["Etat"]]
      end
      true
      
    end

    def import
      data = JSON.parse(File.read(file))
      w.count = data.length

      data.each do |h_cvi_statement| 
        begin  
          convert_keys(h_cvi_statement)
          convert_types(h_cvi_statement)
          calculate_total_area(h_cvi_statement)
          concat_cadastral_reference(h_cvi_statement)
          convert_states(h_cvi_statement)
          import_cvi_statements(h_cvi_statement)
          import_cvi_cadastral_plants(h_cvi_statement)
        rescue StandardError => e
          raise e 
        end
        w.check_point
      end
    end

    private

    def convert_keys(h_cvi_statement)
      h_cvi_statement.transform_keys! { |old_key| HEADER_CONVERSION[old_key] }  
    end

    def import_cvi_cadastral_plants(h_cvi_statement)
      cvi_statement = CviStatement.find_by(cvi_number: h_cvi_statement[:cvi_number])
      CviCadastralPlant.create!(
        h_cvi_statement.to_h.select { |key, _| CVI_CADASTRAL_PLANT_KEYS.include? key }.merge(cvi_statement_id: cvi_statement.id)
      )
    end

    def import_cvi_statements(h_cvi_statement)
      cvi_statement = CviStatement.find_by(cvi_number: h_cvi_statement[:cvi_number])
      if cvi_statement
        total_area = cvi_statement.total_area + h_cvi_statement[:area]
        cadastral_sub_plant_count = cvi_statement.cadastral_sub_plant_count + 1
        cadastral_plant_count = if !h_cvi_statement[:sub_plot_number] || h_cvi_statement[:sub_plot_number] == '1'
                                  cvi_statement.cadastral_plant_count + 1
                                else
                                  cvi_statement.cadastral_plant_count
                                end
        cvi_statement.update(cadastral_sub_plant_count: cadastral_sub_plant_count, cadastral_plant_count: cadastral_plant_count, total_area: total_area)
      else
        CviStatement.create!(
          h_cvi_statement.to_h.select { |key, _| CVI_STATEMENT_KEYS.include? key }.merge(cadastral_sub_plant_count: 1, cadastral_plant_count: 1)
        )
      end
    end

    def convert_types(h_cvi_statement)
      %i[extraction_date property_assessment_change].each do |key|
        h_cvi_statement[key] = Date.parse(h_cvi_statement[key]) unless h_cvi_statement[key].empty?
      end

      %i[ha_area ar_area ca_area inter_vine_plant_distance inter_h_cvi_statement_distance].each do |key|
        h_cvi_statement[key] = h_cvi_statement[key].to_i if h_cvi_statement[key]
      end
    end

    def convert_states(h_cvi_statement)
      h_cvi_statement[:state] = STATES[h_cvi_statement[:state]]
    end

    def concat_cadastral_reference(h_cvi_statement)
      h_cvi_statement[:cadastral_reference] = if h_cvi_statement[:sub_plot_number].to_s.empty?
                h_cvi_statement[:plot_number].to_s.rjust(4, '0')
             else
               "#{h_cvi_statement[:plot_number].to_s.rjust(4, '0')}-#{h_cvi_statement[:sub_plot_number]}"
             end
    end

    def calculate_total_area(h_cvi_statement)
      total_area = h_cvi_statement[:ha_area] + 0.01 * h_cvi_statement[:ar_area] + 0.0001 * h_cvi_statement[:ca_area]
      h_cvi_statement[:total_area] = total_area
      h_cvi_statement[:area] = total_area
      %i[ha_area ar_area ca_area].each do |key|
        h_cvi_statement.delete(key)
      end
    end
  end
end
