class AddPlantingCampaignToActivityProductions < ActiveRecord::Migration
  def change
    add_reference :activity_productions, :planting_campaign, index: true
  end
end
