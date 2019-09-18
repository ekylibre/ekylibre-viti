class CreateCviCadastralPlants < ActiveRecord::Migration
  def change
    create_table :cvi_cadastral_plants do |t|
      t.string :commune, null: false
      t.string :locality
      t.string :cadastral_reference, null: false
      t.string :product, null: false
      t.string :grape_variety, null: false
      t.string :area, null: false
      t.string :campaign, null: false
      t.string :rootstock
      t.integer :inter_vine_plant_distance, null: false
      t.integer :inter_row_distance, null: false
      t.string :state, null: false
      t.references :cvi_statement, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
