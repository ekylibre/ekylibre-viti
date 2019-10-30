require 'test_helper'

module Sage
  module ISeven
    class JournalEntriesExchangerTest < ActiveExchanger::TestCase
      test 'import' do
        Sage::ISeven::JournalEntriesExchanger.import(fixture_files_path.join('imports', 'sage', 'i_seven', 'journal_entries.ecx'))
      end
    end
  end
end
