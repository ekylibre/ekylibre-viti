require 'test_helper'
require_relative '../../test_helper'

module Ekylibre
  class CviCsvExchangerTest < ActiveExchanger::TestCase
    setup do
      @path = EkylibreEkyviti::Engine.root.join('test', 'fixture-files','imports', 'ekylibre','cvi.csv')
      @data = CSV.parse(File.read(@path), {headers: true}).map(&:to_h)
    end

    should 'create the right number of CVI statement' do
      cvi_statement_count = @data.uniq { |cvi| cvi['CVI_ID'] }.length
      assert_difference 'CviStatement.count', cvi_statement_count do
        Ekylibre::CviCsvExchanger.build(@path).run
      end
    end

    should 'create the right number of CVI cadastral plant' do
      cvi_cadastral_plant_count = @data.length
      assert_difference 'CviCadastralPlant.count', cvi_cadastral_plant_count do
        Ekylibre::CviCsvExchanger.build(@path).run
      end
    end

    should 'calculate the right total area' do
      Ekylibre::CviCsvExchanger.build(@path).run
      cvi_statement = CviStatement.last
      cvi_cadastral_plants  = CviCadastralPlant.where(cvi_statement_id: cvi_statement.id)
      cvi_cadastral_plants_total_area = cvi_cadastral_plants.map { |e| e.state == :planted ? e.area.to_f : 0 }.sum
      assert_equal cvi_statement.total_area.to_f, cvi_cadastral_plants_total_area
    end
  end
end
