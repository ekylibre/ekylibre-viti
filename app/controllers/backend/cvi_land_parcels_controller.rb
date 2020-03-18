module Backend
  class CviLandParcelsController < Backend::CviBaseController
    manage_restfully only: %i[edit]

    def index
      records = CviCultivableZone.find(params[:id]).cvi_land_parcels.collect do |r|
        { uuid: r.id, shape: Charta.new_geometry(r.shape.to_rgeo).to_json_object, name: r.name, updated: r.updated? }
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_land_parcel = find_and_check(:cvi_land_parcel)

      @cvi_land_parcel.attributes = update_params
      if @cvi_land_parcel.save
        notify_success(:record_x_updated, record: @cvi_land_parcel.model_name.human,
                                          column: @cvi_land_parcel.human_attribute_name(:name),
                                          name: @cvi_land_parcel.send(:name))
      else
        render action: :edit
      end
    end

    def edit_multiple
      @cvi_land_parcels = CviLandParcel.find(params[:ids])
      rootstock_editable?
      result = ConcatCviLandParcels.call(cvi_land_parcels: @cvi_land_parcels)
      @cvi_land_parcel = result.cvi_land_parcel
    end

    def update_multiple
      @cvi_land_parcels = CviLandParcel.find(params[:ids])
      @cvi_land_parcel = CviLandParcel.new(update_multiple_params)
      unless @cvi_land_parcel.valid_for_update_multiple?
        notify_error_now :records_cannot_be_saved.tl
        response.headers['X-Return-Code'] = 'invalid'
        rootstock_editable?
        render :edit_multiple
        return
      end

      @cvi_land_parcels.each do |cvi_land_parcel|
        update_params = update_multiple_params
        update_params['land_parcel_rootstocks_attributes']['0']['id'] = cvi_land_parcel.land_parcel_rootstock_ids.first if rootstock_editable?
        cvi_land_parcel.update!(update_params.reject { |_k, v| v.blank? })
      end
      response.headers['X-Return-Code'] = 'success'
      notify_success(:records_x_updated_f, record: @cvi_land_parcel.model_name.human.pluralize,
                                           column: @cvi_land_parcel.human_attribute_name(:name),
                                           name: @cvi_land_parcels.collect(&:name).uniq.join(','))
    end

    def group
      cvi_land_parcels = CviLandParcel.joins(:locations).where(id: params[:cvi_land_parcel_ids]).distinct
      result = GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
      if result.success?
        notify_now(:grouped, name_pluralized: CviLandParcel.model_name.human.pluralize.downcase)
        render :update
      else
        notify_error(result.error)
        render partial: 'notify', locals: { attributes: result.attributes, ids: params[:cvi_land_parcel_ids] }
      end
    end

    def pre_split
      @cvi_land_parcel = CviLandParcel.find(params[:id])
      if @cvi_land_parcel.regrouped?
        notify_error(:can_not_split_grouped)
        render partial: 'notify', format: [:js]
      end
    end

    def split
      cvi_land_parcel = CviLandParcel.find(params[:id])
      new_cvi_land_parcels_params = params[:new_cvi_land_parcels].values.map do |h|
        h['shape'] = Charta.new_geometry(h['shape']).to_rgeo
        h
      end
      SplitCviLandParcel.call(cvi_land_parcel: cvi_land_parcel, new_cvi_land_parcels_params: new_cvi_land_parcels_params)
      if result.success?
        notify_now(:cvi_land_parcels_splitted)
        render :update
      else
        notify_error(result.error)
        render partial: 'notify'
      end
      notify_now(:cvi_land_parcels_splitted)
      render :update
    end

    private

      def rootstock_editable?
        @rootstock_editable ||= @cvi_land_parcels.none? { |cvi_land_parcel| cvi_land_parcel.land_parcel_rootstocks.length > 1 }
      end

      def update_params
        params.require(:cvi_land_parcel).permit(:name, :designation_of_origin_id, :vine_variety_id, :planting_campaign, :state, :inter_row_distance_value, :inter_vine_plant_distance_value, :shape, :land_modification_date, :rootstock_id)
              .tap { |h| h['shape'] = h['shape'] && Charta.new_geometry(h['shape']).to_rgeo }
      end

      def update_multiple_params
        params.require(:cvi_land_parcel).permit(:name, :designation_of_origin_id, :vine_variety_id, :planting_campaign, :state, :inter_row_distance_value, :inter_vine_plant_distance_value, :land_modification_date, land_parcel_rootstocks_attributes: %i[rootstock_id])
      end
  end
end
