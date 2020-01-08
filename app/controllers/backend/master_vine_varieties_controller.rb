module Backend
  class MasterVineVarietiesController < Backend::BaseController
    unroll :specie_name, method: :unroll_vine_varieties, scope: :vine_varieties
    unroll :specie_name, method: :unroll_rootstocks, scope: :rootstocks
  end
end
