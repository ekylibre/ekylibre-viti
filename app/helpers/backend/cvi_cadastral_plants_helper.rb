module Backend
  module CviCadastralPlantsHelper
    def range_slider_values(maximum, params = nil, minimum = 0)
      if params.present?
        params.split(',').map do |number|
          number = number.to_f
          number.to_i if number == number.to_i
          number
        end
      else
        [minimum, maximum]
      end
    end
  end
end
