require 'test_helper'

module Ekylibre
  class CviExchangerTest < ActiveExchanger::TestCase
    test 'import' do
      Ekylibre::CviExchanger.import(fixture_files_path.join('imports', 'ekylibre', 'cvi.csv'))
    end
  end
end