module Backend
  class CviLandParcelsController < Backend::CviBaseController
    manage_restfully only: %i[edit]

    def index
      records = CviCultivableZone.find(params[:id]).cvi_land_parcels.collect do |r|
        { uuid: r.id, shape: Charta.new_geometry(r.shape.to_rgeo.simplify(0)).to_json_object, name: r.name, updated: r.updated? }
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_land_parcel = find_and_check(:cvi_land_parcel)

      @cvi_land_parcel.attributes = permitted_params
      if @cvi_land_parcel.save
        notify_success(:record_x_updated, record: @cvi_land_parcel.model_name.human, column: @cvi_land_parcel.human_attribute_name(:name), name: @cvi_land_parcel.send(:name))
      else
        render action: :edit
      end
    end

    def group
      cvi_land_parcels = CviLandParcel.joins(:locations, :land_parcel_rootstocks).find(params[:cvi_land_parcel_ids])
      result = GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
      if result.success?
        notify_now(:cvi_land_parcels_grouped)
        render :update
      else
        notify_error(result.error)
        render partial: 'notify', locals: { attributes: result.attributes, ids: params[:cvi_land_parcel_ids] }
      end
    end

    def pre_split
      @cvi_land_parcel = CviLandParcel.find(params[:id])
    end

    def split
      cvi_land_parcel = CviLandParcel.find(params[:id])
      new_cvi_land_parcels_params = params[:new_cvi_land_parcels].values.map do |h|
        h['shape'] = Charta.new_geometry(h['shape']).to_rgeo
        h
      end
      SplitCviLandParcel.call(cvi_land_parcel: cvi_land_parcel, new_cvi_land_parcels_params: new_cvi_land_parcels_params)
      notify_now(:cvi_land_parcels_splitted)
      render :update
    end

    private

    def permitted_params
      params.require(:cvi_land_parcel).permit(:name, :designation_of_origin_id, :vine_variety_id, :rootstock_id, :planting_campaign, :state, :inter_row_distance_value, :inter_vine_plant_distance_value, :shape, :designation_of_origin,:land_modification_date, :activity_id, land_parcel_rootstocks_attributes: %i[id rootstock_id])
            .tap { |h| h['shape'] = h['shape'] && Charta.new_geometry(h['shape']).to_rgeo }
    end
  end
end
