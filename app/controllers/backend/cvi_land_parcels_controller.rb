module Backend
  class CviLandParcelsController < Backend::BaseController
    manage_restfully only: %i[edit]
    after_filter -> { flash.discard }, if: -> { request.xhr? }

    def index
      records = CviCultivableZone.find(params[:id]).cvi_land_parcels.collect do |r|
        { uuid: r.id, shape: Charta.new_geometry(r.shape.to_rgeo.simplify(0)).to_json_object, name: r.name, updated: r.updated? }
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_land_parcel = find_and_check(:cvi_land_parcel)

      t3e(@cvi_land_parcel.attributes)
      @cvi_land_parcel.attributes = permitted_params
      return if save_and_redirect(@cvi_land_parcel, notify: :record_x_updated, identifier: :name)

      render action: :edit
    end

    def group
      cvi_land_parcels = CviLandParcel.joins(:locations, :land_parcel_rootstocks).find(params[:cvi_land_parcel_ids])
      result = GroupCviLandParcels.call(cvi_land_parcels: cvi_land_parcels)
      if result.success?
        cvi_cultivable_zone = result.new_cvi_land_parcel.cvi_cultivable_zone
        notify_now(:cvi_land_parcels_grouped)
        render 'update.js.erb'
      else
        notify_error(result.error)
        render partial: 'notify.js.erb'
      end
    end

    private

    def permitted_params
      params.require(:cvi_land_parcel).permit(:name, :designation_of_origin_id, :vine_variety_id, :rootstock_id, :planting_campaign, :state, :inter_row_distance_value, :inter_vine_plant_distance_value, :shape, :designation_of_origin,:removed_at, land_parcel_rootstocks_attributes: %i[id rootstock_id])
            .tap { |h| h['shape'] = h['shape'] && Charta.new_geometry(h['shape']).to_rgeo }
    end

    def save_and_redirect(record, options = {})
      record.attributes = options[:attributes] if options[:attributes]
      ActiveRecord::Base.transaction do
        can_be_saved = record.new_record? ? record.createable? : record.updateable?

        if record.updateable? && (options[:saved] || record.save)
          response.headers['X-Return-Code'] = 'success'
          model = record.class
          notify_success(options[:notify],
                           record: model.model_name.human,
                           column: model.human_attribute_name(options[:identifier]),
                           name: record.send(options[:identifier]))
          return true
        else
          raise ActiveRecord::Rollback
        end
      end
      notify_error_now :record_cannot_be_saved.tl
      response.headers['X-Return-Code'] = 'invalid'
      false
    end
  end
end
