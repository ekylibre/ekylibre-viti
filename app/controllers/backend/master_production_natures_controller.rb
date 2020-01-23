module Backend
  class MasterProductionNaturesController < Backend::BaseController
    manage_restfully only: %i[show]

    unroll :human_name_fra
  end
end
