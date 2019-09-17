module Backend
  class CviStatementsController < Backend::BaseController
    manage_restfully

    list do |t|
      t.action :edit
      t.action :destroy, if: :destroyable?
      t.column :cvi_number, url: true
      t.column :extraction_date
      t.column :declarant
      t.column :farm_name
      t.column :total_area, label_method: :total_area_formated
      t.column :state
    end

  end
end