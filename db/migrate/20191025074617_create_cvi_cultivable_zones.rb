class CreateCviCultivableZones < ActiveRecord::Migration
  def change
    create_table :cvi_cultivable_zones do |t|
      t.string :name, null: false
      t.string :calculated_area_unit
      t.decimal :calculated_area_value
      t.string :land_parcels_status
      t.geometry :shape, srid: 4326
      t.references :cvi_statement, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
