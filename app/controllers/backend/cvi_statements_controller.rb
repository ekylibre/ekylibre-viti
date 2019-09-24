module Backend
  class CviStatementsController < Backend::BaseController
    manage_restfully

    list do |t|
      t.action :edit
      t.action :destroy, if: :destroyable?
      t.column :cvi_number, url: true
      t.column :extraction_date
      t.column :declarant
      t.column :farm_name
      t.column :measure_value_value, label_method: :total_area_formated
      t.column :state
    end

    list(:cvi_cadastral_plants, conditions: { cvi_statement_id: 'params[:id]'.c }) do |t|
      t.column :commune
      t.column :locality
      t.column :cadastral_reference
      t.column :designation_of_origin_name
      t.column :vine_variety_name
      t.column :measure_value_value, label_method: :area_formated
      t.column :campaign
      t.column :rootstock_number
      t.column :inter_vine_plant_distance
      t.column :inter_row_distance
      t.column :state
    end
  end
end