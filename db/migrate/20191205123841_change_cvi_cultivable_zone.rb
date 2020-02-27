class ChangeCviCultivableZone < ActiveRecord::Migration
  def change
    execute('DROP VIEW IF EXISTS formatted_cvi_cultivable_zones')
    remove_column :cvi_cultivable_zones, :communes, :string
    remove_column :cvi_cultivable_zones, :cadastral_references, :string
    remove_column :cvi_cultivable_zones, :formatted_declared_area, :string
    remove_column :cvi_cultivable_zones, :formatted_calculated_area, :string

    reversible do |dir|
      dir.down { execute('DROP VIEW IF EXISTS formatted_cvi_cultivable_zones') }
    end
  end
end
