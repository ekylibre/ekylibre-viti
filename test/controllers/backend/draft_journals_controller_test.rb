require 'test_helper'
module Backend
  class DraftJournalsControllerTest < Ekylibre::Testing::ApplicationControllerTestCase::WithFixtures
    test_restfully_all_actions show: :index, confirm: :post_and_redirect, list_journal_entry_items: :list
  end
end
