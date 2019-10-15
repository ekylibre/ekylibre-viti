module Backend
  class CviCadastralPlantsController < Backend::BaseController
    respond_to :json

    def index
      records = CviStatement.find(params[:id]).cvi_cadastral_plants.collect do |r|
        { uuid: r.id, shape: r.land_parcel.shape.to_json_object, cadastral_ref: r.cadastral_reference }
      end
      respond_with records.to_json
    end
  end
end
