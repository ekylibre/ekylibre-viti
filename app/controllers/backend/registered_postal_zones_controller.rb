module Backend
  class RegisteredPostalZonesController < Backend::BaseController
    unroll :city_name, :postal_code
  end
end
