require 'test_helper'
module Backend
  class EventParticipationsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions show: :redirected_get, index: :redirected_get
  end
end
