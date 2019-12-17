class CreateLandParcelRootstocks < ActiveRecord::Migration
  def change
    create_table :land_parcel_rootstocks do |t|
      t.decimal :percentage, default: 1.0
      t.string :rootstock_id
      t.references :land_parcel, polymorphic: true

      t.timestamps null: false
    end
  end
end
