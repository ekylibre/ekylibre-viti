module Ekylibre
  class CviCsvExchanger < ActiveExchanger::Base
    include CviComputation

    category :plant_farming
    vendor :ekylibre

    def check
      file_extension = File.extname(file)
      raise :wrong_file_extension.tl(file_extension: file_extension, required_file_extension: '.csv') if file_extension != '.csv'

      CSV.foreach(file, headers: true, header_converters: ->(h) { HEADER_CONVERSION[h] || (raise :unknown_column_name.tl(column_name: h)) }) do |row|
        raise :unknown_state.tl(state: row[:state]) unless STATES[row[:state]]
        raise :invalid_siret.tl(value: row[:siret_number]) unless Luhn.valid?(row[:siret_number])
      end

      @cvi_row_list = CSV.new(File.open(file).read, headers: true, header_converters: ->(h) { HEADER_CONVERSION[h] }).to_a.map(&:to_hash)

      raise :cvi_statement_already_exist.tl if cvi_statement_already_exist?

      true
    end
  end
end
