module Backend
  class CviCultivableZonesController < Backend::BaseController
    manage_restfully only: %i[edit patch update destroy]

    def index
      records = CviStatement.find(params[:id]).cvi_cultivable_zones.collect do |r|
        { uuid: r.id, shape: r.shape.to_json_object, name: r.name }
      end
      render json: records.compact.to_json
    end


    def update
      return unless @cvi_cultivable_zone = find_and_check(:cvi_cultivable_zone)

      t3e(@cvi_cultivable_zone.attributes)
      @cvi_cultivable_zone.attributes = permitted_params
      return if save_and_redirect(@cvi_cultivable_zone)

      render action: :edit
    end

    def delete_modal; end 

    private

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
