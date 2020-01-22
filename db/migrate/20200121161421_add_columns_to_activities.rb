class AddColumnsToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :production_started_on, :date
    add_column :activities, :production_stopped_on, :date
    add_column :activities, :first_production_after, :integer
  end
end
