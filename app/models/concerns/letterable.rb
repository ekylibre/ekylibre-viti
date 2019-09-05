# Provides methods to letter something from corresponding bank_statement_items.
# Used by Incoming and Outgoing Payments.
module Letterable
  extend ActiveSupport::Concern

  def letter_with(bank_statement_items)
    letterable_items(bank_statement_items)
    return false unless bank_statement_items

    join_to_bank_statement_items(bank_statement_items)
  end

  protected

  def join_to_bank_statement_items(bank_statement_items)
    cash = bank_statement_items.first.cash
    letter = cash.next_reconciliation_letter
    JournalEntryItem
      .where(id: journal_entry.items.to_a
                              .select { |item| item.balance == relative_amount })
      .update_all(bank_statement_letter: letter)
    bank_statement_items.update_all(letter: letter)
  end

  def letterable_items(bank_statement_items)
    return false unless journal_entry && bank_statement_items.present?

    cash_id = bank_statement_items.first.cash.id
    return false unless mode.cash_id == cash_id

    # items = BankStatementItem.where(id: bank_statement_items)
    bank_items_balance = bank_statement_items.sum(:credit) - bank_statement_items.sum(:debit)
    return false unless relative_amount == bank_items_balance
    bank_statement_items
  end
end
