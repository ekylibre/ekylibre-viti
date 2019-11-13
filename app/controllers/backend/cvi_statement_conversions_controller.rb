module Backend
  class CviStatementConversionsController < Backend::BaseController
    manage_restfully only: %i[show], model_name: 'CviStatement'

    list(:cvi_cultivable_zones, conditions: { cvi_statement_id: 'params[:id]'.c }) do |t|
      t.column :id, hidden: true
      t.action :edit
      t.action :destroy
      t.column :name
      t.column :communes, label: :communes
      t.column :cadastral_references, label: :cadastral_references
      t.column :formatted_declared_area, label: :declared_area
      t.column :formatted_calculated_area, label: :calculated_area
      t.column :land_parcels_status
      t.action :create_land_parcels
    end

    def create
      cvi_statement = CviStatement.find(params[:id])
      campaign = Campaign.find_by(name: params[:campaign])
      cvi_statement.update(campaign_id: campaign.id)
      GenerateCviCultivableZones.call(cvi_statement: cvi_statement)
      redirect_to action: 'show', id: cvi_statement.id
    end
  end
end
