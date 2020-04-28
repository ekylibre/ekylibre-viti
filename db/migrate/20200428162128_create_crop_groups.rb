class CreateCropGroups < ActiveRecord::Migration
  def change
    create_table :crop_groups do |t|
      t.string :name, null: false
      t.string :target, default: 'plant'

      t.timestamps null: false
    end
  end
end
