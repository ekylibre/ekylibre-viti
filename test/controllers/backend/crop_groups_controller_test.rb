require 'test_helper'

class Backend::CropGroupsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
  test_restfully_all_actions except: %i[kujaku_options]
end
