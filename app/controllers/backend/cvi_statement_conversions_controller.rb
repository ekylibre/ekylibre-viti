module Backend
  class CviStatementConversionsController < Backend::CviBaseController
    manage_restfully only: %i[show], model_name: 'CviStatement'

    before_action :cvi_cultivable_zones_exist?, only: :show

    list(:cvi_cultivable_zones, selectable: true,
                                select:
                                  [
                                    'cvi_cultivable_zones.*',
                                    ["string_agg(
                                        DISTINCT(
                                          CASE
                                            WHEN land_parcel_number IS NULL THEN section || work_number
                                            ELSE section || work_number ||'-' || land_parcel_number
                                          END
                                          ),', '
                                        )", "cadastral_references"],
                                    ["INITCAP(string_agg(DISTINCT city_name,', ' ORDER BY city_name))", "communes"],
                                  ],
                                joins:
                                  "LEFT JOIN locations as locations ON cvi_cultivable_zones.id = locations.localizable_id AND locations.localizable_type = 'CviCultivableZone'
                                   LEFT JOIN cvi_cadastral_plants ON cvi_cultivable_zones.id = cvi_cadastral_plants.cvi_cultivable_zone_id
                                   LEFT JOIN registered_postal_codes ON locations.registered_postal_zone_id = registered_postal_codes.id",
                                group: "cvi_cultivable_zones.id",
                                count: 'DISTINCT cvi_cultivable_zones.id',
                                conditions: { cvi_statement_id: 'params[:id]'.c },
                                line_class: 'RECORD.land_parcels_status'.c) do |t|
      t.action :edit, url: { controller: 'cvi_cultivable_zones', action: 'edit', remote: true }
      t.action :delete_modal, url: { controller: 'cvi_cultivable_zones', action: 'delete_modal', remote: true }, icon_name: 'delete'
      t.column :name
      t.column :communes
      t.column :cadastral_references, label: :cadastral_references
      t.column :calculated_area, label_method: 'calculated_area&.to_s(:ha_a_ca)', sort: :calculated_area_value, label: :surface
      t.column :declared_area, label_method: 'declared_area&.to_s(:ha_a_ca)', sort: :declared_area_value, label: :cvi_land_parcels_declared_area
      t.column :cvi_land_parcels_calculated_area, label_method: 'cvi_land_parcels.collect(&:calculated_area).sum.to_s(:ha_a_ca)', label: :cvi_land_parcels_calculated_area
      t.column :land_parcels_status
      t.action :generate_cvi_land_parcels, unless: :has_cvi_land_parcels?, url: { controller: 'cvi_cultivable_zones' }
      t.action :edit_cvi_land_parcels, if: :has_cvi_land_parcels?, url: { controller: 'cvi_cultivable_zones' }
      t.action :reset,  if: :has_cvi_land_parcels?, url: { controller: 'cvi_cultivable_zones', action: 'reset_modal', remote: true }
    end

    def create
      cvi_statement = CviStatement.find(params[:id])
      result = GenerateCviCultivableZones.call(cvi_statement: cvi_statement)
      if result.success?
        campaign = Campaign.find_or_create_by(harvest_year: params[:campaign].to_i)
        cvi_statement.update(campaign_id: campaign.id)
        redirect_to action: 'show', id: cvi_statement.id
      else
        notify_error(result.error)
        redirect_to backend_cvi_statement_path(cvi_statement)
      end
    end

    def reset
      cvi_statement = CviStatement.find(params[:id])
      cvi_statement.cvi_cultivable_zones.destroy_all
      notify_success(:cvi_conversion_has_been_correctly_reseted.tl)
      GenerateCviCultivableZones.call(cvi_statement: cvi_statement)
      redirect_to action: 'show', id: cvi_statement.id
    end

    def convert_modal; end

    def convert
      cvi_statement = CviStatement.find(params[:id])
      result = ConvertCvi::Base.call(cvi_statement_id: cvi_statement.id)
      if result.success?
        cvi_statement.update(state: :converted)
        notify(:cvi_converted.tl)
        redirect_to backend_cvi_statements_path
      else
        notify_error(result.error)
        redirect_to action: 'show', id: cvi_statement.id
      end
    end

    private

    def cvi_cultivable_zones_exist?
      cvi_statement = CviStatement.find(params[:id])
      raise ActiveRecord::RecordNotFound if cvi_statement.cvi_cultivable_zones.empty?
    end
  end
end
