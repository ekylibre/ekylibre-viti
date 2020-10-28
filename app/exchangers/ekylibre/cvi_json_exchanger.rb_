module Ekylibre
  class CviJsonExchanger < ActiveExchanger::Base
    include Ekylibre::CviComputation

    def check
      file_extension = File.extname(file)
      raise wrong_file_extension.tl(file_extension: file_extension, required_file_extension: '.json') if file_extension != '.json'

      @cvi_row_list = JSON.parse(File.read(file))

      cvi_row_list.map do |cvi|
        cvi.each_key do |key|
          raise :unknown_column_name.tl(column_name: key) unless HEADER_CONVERSION[key]
        end
        convert_keys(cvi)
        raise :unknown_state.tl(state: cvi[:state]) unless STATES[cvi[:state]]
        raise :unknown_type_of_occupancy.tl(type_of_occupancy: cvi[:type_of_occupancy]) unless TYPE_OF_OCCUPANCY[cvi[:type_of_occupancy]]
        raise :invalid_siret.tl(value: cvi[:siret_number]) unless Luhn.valid?(cvi[:siret_number])
      end

      raise :cvi_statement_already_exist.tl if cvi_statement_already_exist?

      true
    end

    private

    def convert_keys(h_cvi_statement)
      h_cvi_statement.transform_keys! { |old_key| HEADER_CONVERSION[old_key] }
    end
  end
end
