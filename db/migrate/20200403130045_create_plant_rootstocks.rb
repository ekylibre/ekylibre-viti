class CreatePlantRootstocks < ActiveRecord::Migration
  def change
    create_table :plant_rootstocks do |t|
      t.decimal :percentage
      t.string :rootstock_id
      t.references :plant, index: true

      t.timestamps null: false
    end
  end
end
