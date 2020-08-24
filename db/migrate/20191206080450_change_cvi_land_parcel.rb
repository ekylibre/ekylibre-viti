class ChangeCviLandParcel < ActiveRecord::Migration
  def change
    execute('DROP VIEW IF EXISTS formatted_cvi_land_parcels')
    remove_column :cvi_land_parcels, :commune, :string
    remove_column :cvi_land_parcels, :locality, :string
    remove_reference :cvi_land_parcels, :campaign, index: true, foreign_key: true
    add_column :cvi_land_parcels, :planting_campaign, :string
  end
end