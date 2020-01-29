class AddProviderOnJournalEntries < ActiveRecord::Migration
  def change
    # add providers colums to store pairs on provider / id number on journal entries
    add_column :journal_entries, :providers, :jsonb
  end
end
