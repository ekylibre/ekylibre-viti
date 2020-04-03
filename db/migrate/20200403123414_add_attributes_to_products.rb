class AddAttributesToProducts < ActiveRecord::Migration
  def change
    add_column :products, :vine_variety_id, :string, index: true
    add_column :products, :designation_of_origin_id, :integer, index: true
    add_column :products, :type_of_occupancy, :string
    add_column :products, :certification_label, :string
  end
end
