module Backend
  class CviStatementConversionsController < Backend::BaseController
    manage_restfully only: %i[show], model_name: 'CviStatement'

    list(:cvi_cultivable_zones, conditions: { cvi_statement_id: 'params[:id]'.c }) do |t|
      t.column :id
      t.column :name
      t.column :communes, label_method: :communes
      t.column :cadastral_references, label_method: :cadastral_references
      t.column :declared_area, label_method: :declared_area
      t.column :land_parcels_status
    end
  end
end
