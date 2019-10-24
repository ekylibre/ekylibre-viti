module Backend
  class CviStatementConversionsController < Backend::BaseController
    manage_restfully only: %i[show], model_name: 'CviStatement'
  end
end
