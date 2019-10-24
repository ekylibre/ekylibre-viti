require 'test_helper'
module Backend
  class CviStatementConversionsControllerTest < ActionController::TestCase
    test_restfully_all_actions only: %i[show]
  end
end