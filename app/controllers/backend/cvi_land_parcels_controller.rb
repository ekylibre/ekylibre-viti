module Backend
  class CviLandParcelsController < Backend::CviBaseController
    manage_restfully only: %i[edit]
    before_action :new_vine_activity_params, only: %i[edit edit_multiple update update_multiple]

    def index
      records = CviCultivableZone.find(params[:id]).cvi_land_parcels.collect do |r|
        { uuid: r.id, shape: Charta.new_geometry(r.shape.to_rgeo).to_json_object, name: r.name, year: r.planting_campaign, vine_variety: r.vine_variety&.specie_name, updated: r.updated? }
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_land_parcel = find_and_check(:cvi_land_parcel)
      @cvi_cultivable_zone = @cvi_land_parcel.cvi_cultivable_zone

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
      result = ConcatCviLandParcels.call(cvi_land_parcels: @cvi_land_parcels)
      @cvi_land_parcel = result.cvi_land_parcel
    end

    def update_multiple
      @cvi_land_parcels = CviLandParcel.find(params[:ids])
      @cvi_land_parcel = CviLandParcel.new(update_multiple_params)
      @cvi_cultivable_zone = @cvi_land_parcels.first.cvi_cultivable_zone
      @cvi_land_parcel.tap do |r|
        r.valid?
        r.errors.delete(:name)
        r.errors.delete(:shape)
        r.errors.delete(:inter_vine_plant_distance_value) if r.errors.added?(:inter_vine_plant_distance_value, :blank)
        r.errors.delete(:inter_row_distance_value) if r.errors.added?(:inter_row_distance_value, :blank)
        r.errors.delete(:vine_variety_id) if r.errors.added?(:vine_variety_id, :blank)
        r.errors.delete(:activity_id) if r.errors.added?(:activity_id, :blank)
      end
      unless @cvi_land_parcel.errors.empty?
        notify_error_now :records_cannot_be_saved.tl
        response.headers['X-Return-Code'] = 'invalid'
        render :edit_multiple
        return
      end

      @cvi_land_parcels.each do |cvi_land_parcel|
        cvi_land_parcel.attributes = update_multiple_params.reject { |_k, v| v.blank? }
        cvi_land_parcel.save!(context: :update_multiple)
      end
      response.headers['X-Return-Code'] = 'success'
      notify_success(:records_x_updated_f, record: @cvi_land_parcel.model_name.human.pluralize,
                                           column: @cvi_land_parcel.human_attribute_name(:name),
                                           name: @cvi_land_parcels.collect(&:name).uniq.join(','))
    end

    def group
      cvi_land_parcels = CviLandParcel.joins(:locations).where(id: params[:cvi_land_parcel_ids]).distinct
      @cvi_cultivable_zone = cvi_land_parcels.first.cvi_cultivable_zone
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
      @cvi_cultivable_zone = cvi_land_parcel.cvi_cultivable_zone
      new_cvi_land_parcels_params = params[:new_cvi_land_parcels].values.map do |h|
        h['shape'] = Charta.new_geometry(h['shape']).to_rgeo
        h
      end
      result = SplitCviLandParcel.call(cvi_land_parcel: cvi_land_parcel, new_cvi_land_parcels_params: new_cvi_land_parcels_params)
      if result.success?
        notify_now(:cvi_land_parcels_splitted)
        render :update
      else
        notify_error(result.error)
        render partial: 'notify'
      end
    end

    def new_vine_activity_params
      vine_default_production = MasterProductionNature.find_by(specie: 'vitis')
      @new_vine_activity_params = {
        family: 'vine_farming',
        production_nature_id: vine_default_production&.id,
        cultivation_variety: 'vitis',
        production_cycle: 'perennial',
        countings_hidden: true,
        seasons_hidden: true,
        tactics_hidden: true,
        inspections_hidden: true
      }
    end

    private

    def update_params
      params.require(:cvi_land_parcel).permit(:name, :designation_of_origin_id, :vine_variety_id, :activity_id, :planting_campaign, :state, :inter_row_distance_value, :inter_vine_plant_distance_value, :shape, :land_modification_date, :rootstock_id)
            .tap { |h| h['shape'] = h['shape'] && Charta.new_geometry(h['shape']).to_rgeo }
    end

    def update_multiple_params
      params.require(:cvi_land_parcel).permit(:name, :designation_of_origin_id, :vine_variety_id, :activity_id, :planting_campaign, :state, :inter_row_distance_value, :inter_vine_plant_distance_value, :land_modification_date, :rootstock_id)
    end
  end
end
