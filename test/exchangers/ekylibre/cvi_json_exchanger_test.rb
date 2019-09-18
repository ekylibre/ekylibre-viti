require 'test_helper'

module Ekylibre
  class CviJsonExchangerTest < ActiveExchanger::TestCase
    setup do 
      @path = fixture_files_path.join('imports', 'ekylibre', 'cvi.json')
      @data = JSON.parse(File.read(@path))
    end

    should "create the right number of CVI statement" do
      cvi_statement_count = @data.uniq { |cvi| cvi[:cvi_number] }.length
      Ekylibre::CviJsonExchanger.import(@path)
      assert_equal cvi_statement_count, CviStatement.all.count
    end

    should "create the right number of CVI cadastral plant" do
      cvi_cadastral_plant_count = @data.length
      Ekylibre::CviJsonExchanger.import(@path)
      assert_equal cvi_cadastral_plant_count, CviCadastralPlant.all.count
    end

    should "calculate the right total area" do
      Ekylibre::CviJsonExchanger.import(@path)
      cvi_statement = CviStatement.last
      cvi_cadastral_plants  = CviCadastralPlant.where(cvi_statement_id:cvi_statement.id)
      cvi_cadastral_plants_total_area = cvi_cadastral_plants.map{ |e| e.area.to_f }.sum
      assert_equal cvi_statement.total_area.to_f,  cvi_cadastral_plants_total_area
    end
  end
end