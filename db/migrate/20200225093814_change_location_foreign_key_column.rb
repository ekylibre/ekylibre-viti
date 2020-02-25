class ChangeLocationForeignKeyColumn < ActiveRecord::Migration
  def up
    execute('DROP VIEW IF EXISTS formatted_cvi_cultivable_zones')
    execute('DROP VIEW IF EXISTS formatted_cvi_cadastral_plants')
    execute('DROP VIEW IF EXISTS formatted_cvi_land_parcels')

    rename_column :locations, :insee_number, :registered_postal_zone_id
  end

  def down
    execute('DROP VIEW IF EXISTS formatted_cvi_cultivable_zones')
    execute('DROP VIEW IF EXISTS formatted_cvi_cadastral_plants')
    execute('DROP VIEW IF EXISTS formatted_cvi_land_parcels')

    rename_column :locations, :registered_postal_zone_id, :insee_number
  end
end
