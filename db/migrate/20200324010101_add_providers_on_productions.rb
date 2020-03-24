class AddProvidersOnProductions < ActiveRecord::Migration
  def change
    # add providers colums to store pairs on provider / id number on activities / activity productions / products
    add_column :products, :providers, :jsonb
    add_column :activity_productions, :providers, :jsonb
  end
end
