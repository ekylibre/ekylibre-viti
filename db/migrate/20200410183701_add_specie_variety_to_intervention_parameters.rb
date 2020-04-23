class AddSpecieVarietyToInterventionParameters < ActiveRecord::Migration
  def change
    add_column :intervention_parameters, :specie_variety, :jsonb, default: '{}'
  end
end
