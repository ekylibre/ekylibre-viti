module Backend
  class CviLandParcelsController < Backend::BaseController
    manage_restfully only: %i[edit]

    def index
      records = CviCultivableZone.find(params[:id]).cvi_land_parcels.collect do |r|
        { uuid: r.id, shape: Charta.new_geometry(r.shape.simplify(0)).to_json_object, name: r.name, updated: r.updated? }
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_land_parcel = find_and_check(:cvi_land_parcel)

      t3e(@cvi_land_parcel.attributes)
      @cvi_land_parcel.attributes = permitted_params
      return if save_and_redirect(@cvi_land_parcel)

      render action: :edit
    end

    private

    def permitted_params
      params.require(:cvi_land_parcel).permit(:name, :vine_variety_id, :rootstock_id, :campaign_id, :state, :inter_row_distance_value, :inter_vine_plant_distance_value, :shape, :designation_of_origin)
            .tap { |h| h['shape'] = h['shape'] && Charta.new_geometry(h['shape']).to_rgeo }
    end

    def save_and_redirect(record, options = {})
      record.attributes = options[:attributes] if options[:attributes]
      ActiveRecord::Base.transaction do
        can_be_saved = record.new_record? ? record.createable? : record.updateable?

        if record.updateable? && (options[:saved] || record.save)
          response.headers['X-Return-Code'] = 'success'
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
