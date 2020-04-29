class Backend::CropGroupsController < Backend::BaseController
  manage_restfully only: %i[index new edit create update destroy]

  list selectable: true do |t|
    t.action :edit
    t.action :destroy, if: :destroyable?
  end
end
