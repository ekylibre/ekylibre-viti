class RenameSpecieVarietyKeys < ActiveRecord::Migration
  def change
     reversible do |dir|
       dir.up do
         execute <<-SQL
          update products
          set specie_variety = specie_variety - 'name' || jsonb_build_object('specie_variety_name', specie_variety->'name')
          where specie_variety ? 'name'
         SQL

         execute <<-SQL
          update products
          set specie_variety = specie_variety - 'uuid' || jsonb_build_object('specie_variety_uuid', specie_variety->'uuid')
          where specie_variety ? 'uuid'
         SQL

         execute <<-SQL
          update products
          set specie_variety = specie_variety - 'providers' || jsonb_build_object('specie_variety_providers', specie_variety->'providers')
          where specie_variety ? 'providers'
         SQL

       end
       dir.down do
         #NOPE
       end
     end
  end
end
