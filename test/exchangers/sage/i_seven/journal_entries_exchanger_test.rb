require 'test_helper'

module Sage
  module ISeven
    class JournalEntriesExchangerTest < ActiveExchanger::TestCase
      test 'import' do
        FinancialYear.delete_all
        Sage::ISeven::JournalEntriesExchanger.import(fixture_files_path.join('imports', 'sage', 'i_seven', 'journal_entries.ecx'))

        journal = Journal.find_by(name: "Ventes eaux-de-vie")
        journal_entry_1 = journal.entries.find_by(number: 1)
        item1 = journal_entry_1.items

        assert_equal 2, journal.entries.count
        assert_equal 4, journal_entry_1.items.count
        assert_equal 4364.8, item1.find_by(account_id: 693).real_credit.to_f
        assert_equal 4363.49, item1.find_by(account_id: 688).real_debit.to_f
        assert_equal 1.06, item1.find_by(account_id: 691).real_debit.to_f
        assert_equal 0.25, item1.find_by(account_id: 692).real_debit.to_f
      end
    end
  end
end
