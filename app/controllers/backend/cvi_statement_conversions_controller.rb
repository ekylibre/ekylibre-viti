module Backend
  class CviStatementConversionsController < Backend::BaseController
    manage_restfully only: %i[show], model_name: 'CviStatement'

    before_action :cvi_cultivable_zones_exist?, only: :show

    list(:cvi_cultivable_zones, model: :formatted_cvi_cultivable_zones, conditions: { cvi_statement_id: 'params[:id]'.c }, line_class: 'RECORD.land_parcels_status'.c) do |t|
      t.action :edit, url: { controller: 'cvi_cultivable_zones', action: 'edit', remote: true }
      t.action :delete_modal, url: { controller: 'cvi_cultivable_zones', action: 'delete_modal', remote: true },  icon_name: 'delete'
      t.column :name
      t.column :communes, label: :communes
      t.column :cadastral_references, label: :cadastral_references
      t.column :formatted_declared_area, label: :declared_area
      t.column :formatted_calculated_area, label: :calculated_area
      t.column :land_parcels_status
      t.action :generate_cvi_land_parcels, unless: :has_cvi_land_parcels?, url: { controller: 'cvi_cultivable_zones' }
      t.action :edit_cvi_land_parcels, if: :has_cvi_land_parcels?, url: { controller: 'cvi_cultivable_zones' }
      t.action :reset,  if: :has_cvi_land_parcels?, url: { controller: 'cvi_cultivable_zones', action: 'reset_modal', remote: true }
    end

    def create
      cvi_statement = CviStatement.find(params[:id])
      campaign = Campaign.find_or_create_by(harvest_year: params[:campaign].to_i)
      cvi_statement.update(campaign_id: campaign.id)
      GenerateCviCultivableZones.call(cvi_statement: cvi_statement)
      redirect_to action: 'show', id: cvi_statement.id
    end

    def reset
      cvi_statement = CviStatement.find(params[:id])
      cvi_statement.cvi_cultivable_zones.destroy_all
      notify_success(:cvi_conversion_has_been_correctly_reseted.tl)
      GenerateCviCultivableZones.call(cvi_statement: cvi_statement)
      redirect_to action: 'show', id: cvi_statement.id
    end

    private

    def cvi_cultivable_zones_exist?
      cvi_statement = CviStatement.find(params[:id])
      raise ActiveRecord::RecordNotFound if cvi_statement.cvi_cultivable_zones.empty?
    end
  end
end
