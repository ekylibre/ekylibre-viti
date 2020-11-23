
require 'test_helper'

class MeasureExtTest < Ekylibre::Testing::ApplicationTestCase::WithFixtures
  test '#to_s measure format' do
    assert_equal '01ha 14a 55ca', Measure.new(1.1455, :hectare).to_s(:ha_a_ca)
    assert_equal '00ha 14a 55ca', Measure.new(0.1455, :hectare).to_s(:ha_a_ca)
  end
end
