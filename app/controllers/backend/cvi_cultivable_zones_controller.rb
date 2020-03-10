module Backend
  class CviCultivableZonesController < Backend::CviBaseController
    manage_restfully only: %i[edit destroy show]

    def self.cvi_land_parcels_conditions
      code = ''
      code = search_conditions(formatted_cvi_land_parcels: %i[name state localities communes planting_campaign designation_of_origin_name vine_variety_name rootstocks]) + " ||= []\n"

      code << "c[0] << ' AND #{FormattedCviLandParcel.table_name}.cvi_cultivable_zone_id = ?'\n"
      code << "c << params[:id].to_i\n"

      # state
      code << "unless params[:state].blank? \n"
      code << "  c[0] << ' AND #{FormattedCviLandParcel.table_name}.state IN (?)'\n"
      code << "  c << params[:state]\n"
      code << "end\n"

      # communes
      code << "unless params[:communes].blank? \n"
      code << "  c[0] << ' AND #{FormattedCviLandParcel.table_name}.communes ILIKE (?)'\n"
      code << "  c <<  '%' + params[:communes] + '%'\n"
      code << "end\n"

      # designation_of_origin_name
      code << "unless params[:designation_of_origin_name].blank? \n"
      code << "  c[0] << ' AND #{FormattedCviLandParcel.table_name}.designation_of_origin_name = ?'\n"
      code << "  c << params[:designation_of_origin_name]\n"
      code << "end\n"

      # vine_variety_name
      code << "unless params[:vine_variety_name].blank? \n"
      code << "  c[0] << ' AND #{FormattedCviLandParcel.table_name}.vine_variety_name = ?'\n"
      code << "  c << params[:vine_variety_name]\n"
      code << "end\n"

      # inter_row_distance
      code << "if params[:inter_row_distance_value] \n"
      code << "  lower,higher = params[:inter_row_distance_value].split(',').map(&:to_i)\n"
      code << "  c[0] << ' AND #{FormattedCviLandParcel.table_name}.inter_row_distance_value BETWEEN ? AND ?'\n"
      code << "  c << lower\n"
      code << "  c << higher\n"
      code << "end\n"

      # inter_vine_plant_distance
      code << "if params[:inter_vine_plant_distance_value]\n"
      code << "  lower,higher = params[:inter_vine_plant_distance_value].split(',').map(&:to_i)\n"
      code << "  c[0] << ' AND #{FormattedCviLandParcel.table_name}.inter_vine_plant_distance_value BETWEEN ? AND ?'\n"
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
      if @cvi_cultivable_zone.save
        notify_success(:record_x_updated, record: @cvi_cultivable_zone.model_name.human, column: @cvi_cultivable_zone.human_attribute_name(:name), name: @cvi_cultivable_zone.send(:name))
      else
        render action: :edit
      end
    end

    def delete_modal; end

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

    def generate_cvi_land_parcels
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      unless cvi_cultivable_zone.cvi_land_parcels.any?
        GenerateCviLandParcels.call(cvi_cultivable_zone: cvi_cultivable_zone)
      end
      redirect_to action: 'show', id: cvi_cultivable_zone.id
    end

    def confirm_cvi_land_parcels
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      shape = CviLandParcel.select('st_astext(
                                      ST_Simplify(
                                        ST_UNION(
                                          ARRAY_AGG(
                                            array[
                                              ST_MakeValid(cvi_land_parcels.shape),
                                              ST_MakeValid(cvi_cultivable_zones.shape)
                                            ]
                                            )
                                          ), 0.000000001
                                        )
                                      ) AS shape').joins(:cvi_cultivable_zone).find_by(cvi_cultivable_zone_id: cvi_cultivable_zone.id).shape
      calculated_area = Measure.new(shape.area, :square_meter).convert(:hectare)
      cvi_cultivable_zone.update(shape: shape.to_rgeo, calculated_area: calculated_area, land_parcels_status: :created)
      redirect_to backend_cvi_statement_conversion_path(cvi_cultivable_zone.cvi_statement)
    end

    list(:cvi_land_parcels, order: 'name DESC', model: :formatted_cvi_land_parcels, conditions: cvi_land_parcels_conditions) do |t|
      t.column :id, hidden: true
      t.action :edit, url: { controller: 'cvi_land_parcels', action: 'edit', remote: true }
      t.column :name
      t.column :communes
      t.column :localities
      t.column :designation_of_origin_name
      t.column :vine_variety_name
      t.column :declared_area_formatted, label: :declared_area
      t.column :calculated_area_formatted, label: :calculated_area
      t.column :rootstocks
      t.column :planting_campaign
      t.column :inter_vine_plant_distance_value
      t.column :inter_row_distance_value
      t.column :state
    end

    def edit_cvi_land_parcels
      cvi_cultivable_zone = CviCultivableZone.find(params[:id])
      cvi_cultivable_zone.update(land_parcels_status: :not_created) if cvi_cultivable_zone.land_parcels_status == :created
      redirect_to backend_cvi_cultivable_zone_path(cvi_cultivable_zone)
    end

    private

    def permitted_params
      params.require(:cvi_cultivable_zone).permit(:name, :shape)
        .tap { |h| h['shape'] = h['shape'] && Charta.new_geometry(h['shape']).to_rgeo }
    end
  end
end
