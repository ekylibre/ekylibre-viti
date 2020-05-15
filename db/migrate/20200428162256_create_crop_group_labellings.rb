class CreateCropGroupLabellings < ActiveRecord::Migration
  def change
    create_table :crop_group_labellings do |t|
      t.references :crop_group, index: true, foreign_key: true
      t.references :label, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
