module Ekylibre
  class CviCsvExchanger < ActiveExchanger::Base
    include CviComputation

    def check
      file_extension = File.extname(file)
      raise ::I18n.translate('exchangers.ekylibre_cvi.errors.wrong_file_extension', file_extension: file_extension, required_file_extension: '.csv') if file_extension != '.csv'

      CSV.foreach(file, headers: true, header_converters: ->(h) { HEADER_CONVERSION[h] || (raise ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_column_name', column_name: h)) }) do |row|
        raise ::I18n.translate('exchangers.ekylibre_cvi.errors.unknown_state', state: row[:state]) unless STATES[row[:state]]
        raise ::I18n.translate('exchangers.ekylibre_cvi.errors.invalid_siret', value: row[:siret_number]) unless Luhn.valid?(row[:siret_number])
      end

      @cvi_row_list = CSV.new(File.open(file).read, headers: true, header_converters: ->(h) { HEADER_CONVERSION[h] }).to_a.map(&:to_hash)

      raise ::I18n.translate('exchangers.ekylibre_cvi.errors.cvi_statement_already_exist') if cvi_statement_already_exist?

      true
    end
  end
end
