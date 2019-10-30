class AddProviderOnJournalEntries < ActiveRecord::Migration
  def up
    # add providers colums to store pairs on provider / id number on journal entries
    add_column :journal_entries, :providers, :jsonb
  end

  def down
    remove_column :journal_entries, :providers
  end
end
