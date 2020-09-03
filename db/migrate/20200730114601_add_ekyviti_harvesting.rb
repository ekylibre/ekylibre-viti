class AddEkyvitiHarvesting < ActiveRecord::Migration
  def change
    create_table :incoming_harvests do |t|
      t.string :number, index: true
      t.string :ticket_number, index: true
      t.text :description
      t.references :campaign, index: true, null: false, foreign_key: true
      t.references :analysis, index: true, foreign_key: true
      t.datetime :received_at, null: false
      t.decimal :quantity_value, precision: 19, scale: 4, null: false
      t.string :quantity_unit, null: false
      t.jsonb :additional_informations, default: {}
      t.stamps
    end

    create_table :incoming_harvest_plants do |t|
      t.references :incoming_harvest, index: true, null: false, foreign_key: true
      t.references :plant, index: true, null: false
      t.decimal :harvest_percentage_received, precision: 19, scale: 4, null: false
      t.stamps
    end

    create_table :incoming_harvest_storages do |t|
      t.references :incoming_harvest, index: true, null: false, foreign_key: true
      t.references :storage, index: true, null: false
      t.decimal :quantity_value, precision: 19, scale: 4, null: false
      t.string :quantity_unit, null: false
      t.stamps
    end

    create_table :incoming_harvest_inputs do |t|
      t.references :incoming_harvest, index: true, null: false, foreign_key: true
      t.references :input, index: true, null: false
      t.decimal :quantity_value, precision: 19, scale: 4, null: false
      t.string :quantity_unit, null: false
      t.stamps
    end
  end
end
