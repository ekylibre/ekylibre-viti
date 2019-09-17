require 'test_helper'

module Ekylibre
  class CviCsvExchangerTest < ActiveExchanger::TestCase
    test 'import' do
      Ekylibre::CviCsvExchanger.import(fixture_files_path.join('imports', 'ekylibre', 'cvi.csv'))
    end
  end
end
