module Backend
  class CviCadastralPlantsController < Backend::BaseController
    manage_restfully only: %i[edit destroy]

    def index
      records = CviStatement.find(params[:id]).cvi_cadastral_plants.collect do |r|
        { uuid: r.id, shape: r.land_parcel.shape.to_json_object, cadastral_ref: r.cadastral_reference } if r.land_parcel
      end
      render json: records.compact.to_json
    end

    def update
      return unless @cvi_cadastral_plant = find_and_check(:cvi_cadastral_plant)

      t3e(@cvi_cadastral_plant.attributes)
      @cvi_cadastral_plant.attributes = permitted_params
      return if save_and_redirect(@cvi_cadastral_plant, notify: :record_x_updated_f, identifier: :cadastral_reference)

      render action: :edit
    end

    private

    def save_and_redirect(record, options = {})
      record.attributes = options[:attributes] if options[:attributes]
      ActiveRecord::Base.transaction do
        can_be_saved = record.new_record? ? record.createable? : record.updateable?

        if record.updateable? && (options[:saved] || record.save)
          response.headers['X-Return-Code'] = 'success'
          if options[:notify]
            model = record.class
            notify_success(options[:notify],
                           record: model.human_attribute_name(options[:identifier]),
                           column: model.human_attribute_name(options[:identifier]),
                           name: record.send(options[:identifier]))
          end
          respond_to do |format|
            format.js   { render js: 'window.location.reload();' }
          end
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
