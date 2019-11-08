module Backend
  class CviCultivableZonesController < Backend::BaseController
    manage_restfully only: %i[edit destroy]

    def index
      records = CviStatement.find(params[:id]).cvi_cultivable_zones.collect do |r|
        { uuid: r.id, shape: r.shape.to_json_object, name: r.name }
      end
      render json: records.compact.to_json
    end

    def create_land_parcels
    end

  end
end
