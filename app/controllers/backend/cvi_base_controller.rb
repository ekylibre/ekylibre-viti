module Backend
  class CviBaseController < Backend::BaseController
    after_action -> { flash.discard }, if: -> { request.xhr? }
  end
end
