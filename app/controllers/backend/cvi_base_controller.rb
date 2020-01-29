module Backend
  class CviBaseController < Backend::BaseController
    after_filter -> { flash.discard }, if: -> { request.xhr? }
  end
end
