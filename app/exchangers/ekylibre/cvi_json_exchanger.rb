module Ekylibre
  class CviJsonExchanger < ActiveExchanger::Base
    include Ekylibre::CviComputation

    def check
      file_extension = File.extname(file)
      raise ::I18n.translate('exchangers.ekylibre_cvi.errors.wrong_file_extension', file_extension: file_extension, required_file_extension: '.json') if file_extension != '.json'

      @cvi_row_list = JSON.parse(File.read(file))

      cvi_row_list.map do |cvi|
        cvi.each_key do |key|
          raise ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_column_name', column_name: key) unless HEADER_CONVERSION[key]
        end
        convert_keys(cvi)
        raise ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_state', state: cvi[:state]) unless STATES[cvi[:state]]
        raise ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_type_of_occupancy', type_of_occupancy: cvi[:type_of_occupancy]) unless TYPE_OF_OCCUPANCY[cvi[:type_of_occupancy]]
        raise ::I18n.translate('exchangers.ekylibre_cvi.errors.invalid_siret', value: cvi[:siret_number]) unless Luhn.valid?(cvi[:siret_number])
      end

      raise ::I18n.translate('exchangers.ekylibre_cvi.errors.cvi_statement_already_exist') if cvi_statement_already_exist?

      true
    end

    private

    def convert_keys(h_cvi_statement)
      h_cvi_statement.transform_keys! { |old_key| HEADER_CONVERSION[old_key] }
    end
  end
end
