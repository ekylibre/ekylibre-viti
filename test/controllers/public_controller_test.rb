require 'test_helper'
class PublicControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
  test 'index' do
    get :index
    assert_response :redirect
  end
end
