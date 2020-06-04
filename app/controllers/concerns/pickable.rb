module Pickable
  extend ActiveSupport::Concern

  module ClassMethods
    def importable_from_lexicon(lexicon_table, model_name: nil, filter_by_nature: nil, filter_by_sub_nature: nil)
      record_name = controller_name.singularize
      model = model_name || controller_name.classify.constantize
      lexicon_model = lexicon_table.to_s.classify.constantize

      define_method :pick do
        instance_variable_set "@#{record_name}", model.new
        @lexicon_table = lexicon_table
        imported_references = model.pluck(:reference_name).uniq.compact
        @imported_ids = lexicon_model.including_references(imported_references).pluck(:id)
        @scopes = {}
        @scopes[:of_class_name] = filter_by_nature if filter_by_nature
        @scopes[:of_sub_nature] = filter_by_sub_nature if filter_by_sub_nature
      end

      define_method :incorporate do
        begin
          reference_name = lexicon_model.find(params[:reference_id]).reference_name
          instance_variable_set "@#{record_name}", model.send('import_from_lexicon', reference_name, true)
          notify_success :record_has_been_imported
          redirect_to params[:redirect] + '/' + instance_variable_get("@#{record_name}").id.to_s
        rescue => e
          notify_error :an_error_was_raised_during_import
          redirect_to params[:redirect] || :back
        end
      end
    end
  end
end
