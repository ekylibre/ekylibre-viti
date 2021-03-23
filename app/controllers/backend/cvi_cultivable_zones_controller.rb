module Backend
  class CviCultivableZonesController < Backend::CviBaseController
    manage_restfully only: %i[edit destroy show]

    def self.cvi_land_parcels_conditions
      code = ''
      code = search_conditions(cvi_land_parcels: %i[name planting_campaign],
                               registered_protected_designation_of_origins: %i[product_human_name_fra],
                               master_vine_varieties: %i[specie_name],
                               "rootstocks_cvi_land_parcels" => %i[specie_name],
                               locations: %i[locality],
                               registered_postal_zones: %i[city_name]) + " ||= []\n"

      code << "c[0] << ' AND cvi_land_parcels.cvi_cultivable_zone_id = ?'\n"
      code << "c << params[:id].to_i\n"

      # state
      code << "unless params[:state].blank? \n"
      code << "  c[0] << ' AND cvi_land_parcels.state IN (?)'\n"
      code << "  c << params[:state]\n"
      code << "end\n"

      # communes
      code << "unless params[:communes].blank? \n"
      code << "  c[0] << ' AND registered_postal_zones.city_name ILIKE (?)'\n"
      code << "  c <<  '%' + params[:communes] + '%'\n"
      code << "end\n"

      # designation_of_origin_name
      code << "unless params[:designation_of_origin_name].blank? \n"
      code << "  c[0] << ' AND registered_protected_designation_of_origins.product_human_name_fra = ?'\n"
      code << "  c << params[:designation_of_origin_name]\n"
      code << "end\n"

      # vine_variety_name
      code << "unless params[:vine_variety_name].blank? \n"
      code << "  c[0] << ' AND master_vine_varieties.specie_name = ?'\n"
      code << "  c << params[:vine_variety_name]\n"
      code << "end\n"

      # inter_row_distance
      code << "if params[:inter_row_distance_value] \n"
      code << "  lower,higher = params[:inter_row_distance_value].split(',').map(&:to_i)\n"
      code << "  c[0] << ' AND cvi_land_parcels.inter_row_distance_value BETWEEN ? AND ?'\n"
      code << "  c << lower\n"
      code << "  c << higher\n"
      code << "end\n"

      # inter_vine_plant_distance
      code << "if params[:inter_vine_plant_distance_value]\n"
      code << "  lower,higher = params[:inter_vine_plant_distance_value].split(',').map(&:to_i)\n"
      code << "  c[0] << ' AND cvi_land_parcels.inter_vine_plant_distance_value BETWEEN ? AND ?'\n"
      code << "  c << lower\n"
      code << "  c << higher\n"
      code << "end\n"

      code << "c\n "
      code.c
    end

    def index
      records = CviStatement.find(params[:id]).cvi_cultivable_zones.collect do |r|
        { uuid: r.id, shape: r.shape.to_json_object, name: r.name, status: r.land_parcels_status }
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_cultivable_zone = find_and_check(:cvi_cultivable_zone)

      @cvi_cultivable_zone.attributes = permitted_params
      @cvi_cultivable_zone.shape = CviCultivableZoneService::ShapeCalculator.calculate(@cvi_cultivable_zone, permitted_params[:shape])
      if @cvi_cultivable_zone.save
        notify_success(:record_x_updated, record: @cvi_cultivable_zone.model_name.human, column: @cvi_cultivable_zone.human_attribute_name(:name), name: @cvi_cultivable_zone.send(:name))
      else
        render action: :edit
      end
    end

    def delete_modal; end

    def reset_modal; end

    def group
      cvi_cultivable_zones = CviCultivableZone.joins(:cvi_cadastral_plants).where(id: params[:cvi_cultivable_zone_ids]).distinct
      result = GroupCviCultivableZones.call(cvi_cultivable_zones: cvi_cultivable_zones)
      if result.success?
        notify_now(:grouped, name_pluralized: CviCultivableZone.model_name.human(count: 2).downcase)
        render :update
      else
        notify_error(result.error)
        render partial: 'notify', locals: { ids: params[:cvi_cultivable_zone_ids] }
      end
    end

    def reset
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      cvi_cultivable_zone.cvi_land_parcels.destroy_all
      GenerateCviLandParcels.call(cvi_cultivable_zone: cvi_cultivable_zone)
      shape = CviLandParcel.select('st_astext(
        ST_Simplify(
          ST_UNION(
            ARRAY_AGG(
                ST_MakeValid(cvi_land_parcels.shape)
              )
            ), 0.000000001
          )
        ) AS shape').joins(:cvi_cultivable_zone).find_by(cvi_cultivable_zone_id: cvi_cultivable_zone.id).shape
      calculated_area = Measure.new(shape.area, :square_meter).convert(:hectare)
      cvi_cultivable_zone.update(shape: shape.to_rgeo, calculated_area: calculated_area, land_parcels_status: :started)
      redirect_to backend_cvi_cultivable_zone_path(cvi_cultivable_zone.id)
    end

    def generate_cvi_land_parcels
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      unless cvi_cultivable_zone.cvi_land_parcels.any?
        GenerateCviLandParcels.call(cvi_cultivable_zone: cvi_cultivable_zone)
      end
      cvi_cultivable_zone.update(land_parcels_status: :started)
      redirect_to action: 'show', id: cvi_cultivable_zone.id
    end

    def confirm_cvi_land_parcels
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      if cvi_cultivable_zone.land_parcels_valid?
        cvi_cultivable_zone.update_shape!
        cvi_cultivable_zone.complete!
        redirect_to backend_cvi_statement_conversion_path(cvi_cultivable_zone.cvi_statement)
      else
        notify_error(:cvi_land_parcels_planting_campaign_invalid.tl)
        redirect_to action: 'show', id: cvi_cultivable_zone.id
      end
    end

    list(:cvi_land_parcels, selectable: true,
                            order: 'name DESC',
                            select:
                              [
                                'cvi_land_parcels.*',
                                ['activities.name', 'activity_name']
                              ],
                            joins:
                              "LEFT JOIN locations ON cvi_land_parcels.id = locations.localizable_id AND locations.localizable_type = 'CviLandParcel'
                               LEFT JOIN registered_postal_zones ON locations.registered_postal_zone_id = registered_postal_zones.id
                               LEFT JOIN activities ON cvi_land_parcels.activity_id = activities.id",
                            conditions: cvi_land_parcels_conditions,
                            count: 'DISTINCT cvi_land_parcels.id',
                            group: 'cvi_land_parcels.id, activities.name, registered_protected_designation_of_origins.id, master_vine_varieties.id, rootstocks_cvi_land_parcels.id') do |t|
      t.column :id, hidden: true
      t.action :edit, url: { controller: 'cvi_land_parcels', action: 'edit', remote: true }
      t.column :name
      t.column :communes, label_method: "locations.collect(&:city_name).compact.uniq.sort.join(', ')"
      t.column :localities, label_method: "locations.pluck(:locality).compact.uniq.sort.join(', ')"
      t.column :product_human_name_fra, through: :designation_of_origin
      t.column :vine_variety_name, through: :vine_variety
      t.column :calculated_area, label_method: 'calculated_area&.to_s(:ha_a_ca)', sort: :calculated_area_value
      t.column :declared_area, label_method: 'declared_area&.to_s(:ha_a_ca)', sort: :declared_area_value
      t.column :rootstock_name, through: :rootstock
      t.column :planting_campaign
      t.column :inter_vine_plant_distance_value, label_method: 'inter_vine_plant_distance_value&.to_i'
      t.column :inter_row_distance_value, label_method: 'inter_row_distance_value&.to_i'
      t.column :state
      t.column :activity_name, label: :activity
    end

    def edit_cvi_land_parcels
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      cvi_cultivable_zone.update(land_parcels_status: :started)
      redirect_to backend_cvi_cultivable_zone_path(cvi_cultivable_zone)
    end

    private

    def permitted_params
      params.require(:cvi_cultivable_zone).permit(:name, :shape)
            .tap { |h| h['shape'] = h['shape'] && Charta.new_geometry(h['shape']).to_rgeo }
    end
  end
end
