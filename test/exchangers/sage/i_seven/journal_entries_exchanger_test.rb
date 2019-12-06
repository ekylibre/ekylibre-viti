require 'test_helper'

module Sage
  module ISeven
    class JournalEntriesExchangerTest < ActiveExchanger::TestCase
      test 'import' do
        FinancialYear.delete_all
        Sage::ISeven::JournalEntriesExchanger.import(fixture_files_path.join('imports', 'sage', 'i_seven', 'journal_entries.ecx'))

        journal1 = Journal.find_by(name: "Ventes eaux-de-vie")
        journal_entry_1 = journal1.entries.find_by(number: 1)
        item1 = journal_entry_1.items

        journal2 = Journal.find_by(name: "C.i.c. Ouest")
        journal_entry_2 = journal2.entries.find_by(number: 1)
        item2 = journal_entry_2.items
        cash_main_account = Cash.find_by(iban: 'FR1420041010050500013M02606').main_account.number

        assert_equal 2, journal1.entries.count
        assert_equal 1, journal2.entries.count
        assert_equal 4364.8, item1.find_by(account_id: 693).real_credit.to_f
        assert_equal 4363.49, item1.find_by(account_id: 688).real_debit.to_f
        assert_equal 1.06, item1.find_by(account_id: 691).real_debit.to_f
        assert_equal 0.25, item1.find_by(account_id: 692).real_debit.to_f


        assert_equal 4, journal_entry_1.items.count
        assert_equal 2, journal_entry_2.items.count
        assert_equal 282.18, item2.find_by(account_id: 694).real_debit.to_f
        assert_equal 282.18, item2.find_by(account_id: 695).real_credit.to_f
        assert_equal '512300000', cash_main_account
        assert Account.find_by(number: '401000483')
      end
    end
  end
end
