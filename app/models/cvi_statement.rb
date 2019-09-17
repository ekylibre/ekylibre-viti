# frozen_string_literal: true

class CviStatement < Ekylibre::Record::Base
  validates :extraction_date, :siret_number, :farm_name, :declarant, :state, presence: true
  validates :siret_number, siret_format: true

  def total_area_formated
    total_area_to_s = (total_area * 10_000).floor.to_s.rjust(6, '0')
    [
      [total_area_to_s[0..-5], 'HA'],
      [total_area_to_s[-4, 2], 'AR'],
      [total_area_to_s[-2, 2], 'CA']
    ].reject { |n| n[0] == '00' }.flatten.join(' ')
  end
end
