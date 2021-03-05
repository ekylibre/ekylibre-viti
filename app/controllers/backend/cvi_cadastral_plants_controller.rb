module Backend
  class CviCadastralPlantsController < Backend::CviBaseController
    manage_restfully only: %i[edit destroy]

    before_action :find_cvi_statement, only: [:update, :destroy]

    def index
      records = CviStatement.find(params[:id]).cvi_cadastral_plants.collect do |r|
        { uuid: r.id, shape: r.land_parcel.shape.to_json_object, cadastral_ref: r.cadastral_reference } if r.land_parcel
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_cadastral_plant = find_and_check(:cvi_cadastral_plant)
      previous_cadastral_land_parcel = @cvi_cadastral_plant
      @cvi_cadastral_plant.attributes = permitted_params

      cadastral_land_parcel = CadastralLandParcelZone.find_with(RegisteredPostalZone.find(permitted_params[:location_attributes][:registered_postal_zone_id])&.code,
                                                                                          permitted_params[:section],
                                                                                          permitted_params[:work_number]).first
      @cvi_cadastral_plant.land_parcel = cadastral_land_parcel
      if previous_cadastral_land_parcel != cadastral_land_parcel
        @cvi_cadastral_plant.cadastral_ref_updated = true
      end

      if @cvi_cadastral_plant.save
        notify_success(:record_x_updated_f, record: @cvi_cadastral_plant.human_attribute_name(:cadastral_reference), name: @cvi_cadastral_plant.send(:cadastral_reference))
      else
        render action: :edit
      end
    end

    def delete_modal; end

    private

      def find_cvi_statement
        cvi_cadastral_plant = CviCadastralPlant.find(params[:id])
        @cvi_statement = cvi_cadastral_plant.cvi_statement if cvi_cadastral_plant.present?
      end
  end
end
