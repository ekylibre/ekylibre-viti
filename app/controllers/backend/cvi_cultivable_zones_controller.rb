module Backend
  class CviCultivableZonesController < Backend::BaseController
    def index
      records = CviStatement.find(params[:id]).cvi_cultivable_zones.collect do |r|
        { uuid: r.id, shape: r.declared_shape.to_json_object, cadastral_ref: nil }
      end
      render json: records.compact.to_json
    end

  end
end
