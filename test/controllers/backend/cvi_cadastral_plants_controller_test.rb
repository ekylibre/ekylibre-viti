require 'test_helper'
require_relative '../../test_helper'

module Backend
  class CviCadastralPlantsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions except: %i[index update delete_modal]
  end
end