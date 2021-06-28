module Backend
  class RegisteredVineVarietiesController < Backend::BaseController
    unroll :short_name, method: :unroll_vine_varieties, scope: :vine_varieties
    unroll :short_name, method: :unroll_rootstocks, scope: :rootstocks
  end
end
