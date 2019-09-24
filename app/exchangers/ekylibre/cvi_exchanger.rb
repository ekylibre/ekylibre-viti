module Ekylibre
  class CviExchanger < ActiveExchanger::Base

    HEADER_CONVERSION = {
      'CVI_ID' => :cvi_number,
      'Date extraction' => :extraction_date,
      'N° SIRET' => :siret_number,
      'Nom Exploitation' => :farm_name,
      'Nom Gestionnaire' => :declarant,
      'Commune' => :commune,
      'Lieu-dit' => :locality,
      'Code INSEE' => :insee_number,
      'feuille' => :section,
      'numéro' => :work_number,
      'Sous Parcelle' => :land_parcel_number,
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

    CVI_STATEMENT_KEYS = %i[cvi_number extraction_date siret_number farm_name declarant].freeze
    CVI_CADASTRAL_PLANT_KEYS = %i[commune locality insee_number section land_parcel_number work_number campaign inter_row_distance inter_vine_plant_distance state].freeze
  end
end
