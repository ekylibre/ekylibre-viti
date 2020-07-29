module Backend
  class CviCadastralPlantsController < Backend::CviBaseController
    manage_restfully only: %i[edit destroy]

    def index
      records = CviStatement.find(params[:id]).cvi_cadastral_plants.collect do |r|
        { uuid: r.id, shape: r.land_parcel.shape.to_json_object, cadastral_ref: r.cadastral_reference } if r.land_parcel
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_cadastral_plant = find_and_check(:cvi_cadastral_plant)

      @cvi_cadastral_plant.attributes = permitted_params
      if @cvi_cadastral_plant.save
        notify_success(:record_x_updated_f, record: @cvi_cadastral_plant.human_attribute_name(:cadastral_reference), name: @cvi_cadastral_plant.send(:cadastral_reference))
      else
        render action: :edit
      end
    end

    def delete_modal; end
  end
end
