class AddProviderOnInterventions < ActiveRecord::Migration
  def up
    # add providers colums to store pairs on provider / id number on article
    unless column_exists?(:interventions, :providers)
      add_column :interventions, :providers, :jsonb
    end
  end

  def down
    remove_column :interventions, :providers
  end
end
