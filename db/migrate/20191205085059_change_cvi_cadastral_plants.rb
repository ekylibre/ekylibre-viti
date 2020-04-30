class ChangeCviCadastralPlants < ActiveRecord::Migration
  def change
    execute('DROP VIEW IF EXISTS formatted_cvi_cadastral_plants')
    rename_column :cvi_cadastral_plants, :campaign, :planting_campaign
    remove_column :cvi_cadastral_plants, :insee_number, :string
    remove_column :cvi_cadastral_plants, :locality, :string
    remove_column :cvi_cadastral_plants, :commune, :string

    reversible do |dir|
      dir.down { execute('DROP VIEW IF EXISTS formatted_cvi_cadastral_plants') }
    end
  end
end
