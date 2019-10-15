module Backend
  class CviCadastralPlantsController < Backend::BaseController
    manage_restfully only: %i[edit destroy patch update]
    before_filter :set_format, only: %i[edit destroy patch update]

    def index
      records = CviStatement.find(params[:id]).cvi_cadastral_plants.collect do |r|
        { uuid: r.id, shape: r.land_parcel.shape.to_json_object, cadastral_ref: r.cadastral_reference }
      end
      render json: records.to_json
    end

    def set_format
      request.format = 'xml'
    end
  end
end