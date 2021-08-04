module Backend
  class RegisteredPostalCodesController < Backend::BaseController
    unroll :city_name, :postal_code
  end
end
