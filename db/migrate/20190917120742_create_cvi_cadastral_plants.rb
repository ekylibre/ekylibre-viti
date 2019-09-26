class CreateCviCadastralPlants < ActiveRecord::Migration
  def change
    create_table :cvi_cadastral_plants do |t|
      t.string :commune, null: false
      t.string :locality
      t.string :insee_number, null: false
      t.string :section, null: false
      t.string :work_number, null: false
      t.string :land_parcel_number
      t.integer :designation_of_origin_id
      t.string :vine_variety_id
      t.decimal :measure_value_value, precision: 19, scale: 4
      t.string :measure_value_unit
      t.string :campaign, null: false
      t.string :rootstock_id
      t.integer :inter_vine_plant_distance, null: false
      t.integer :inter_row_distance, null: false
      t.string :state, null: false
      t.references :cvi_statement, index: true, foreign_key: true
      t.string :land_parcel_id

      t.timestamps null: false
    end
  end
end
