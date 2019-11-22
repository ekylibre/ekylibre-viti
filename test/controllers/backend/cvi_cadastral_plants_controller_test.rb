require 'test_helper'
module Backend
  class CviCadastralPlantsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions only: %i[edit destroy]
  end
end