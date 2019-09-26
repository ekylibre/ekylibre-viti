module Backend
  module CviCadastralPlantsHelper
    def range_slider_values(maximum, params = nil, minimum = 0)
      if params.present?
        params.split(',').map do |number|
          number.include?('.') ? number.to_f : number.to_i
        end
      else
        [minimum, maximum]
      end
    end
  end
end
