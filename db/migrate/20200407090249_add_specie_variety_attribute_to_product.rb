class AddSpecieVarietyAttributeToProduct < ActiveRecord::Migration
  def change
    add_column :products, :specie_variety, :jsonb, default: '{}'
  end
end
