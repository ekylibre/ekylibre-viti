module EkylibreEkyviti
  module MeasureExt
    MEASURE_FORMATS = {
      ha_a_ca: lambda { |area|
        # format area: 1,0056 ha => 01ha 56ca,  1,3456 ha => 01ha 34ar 56ca
        area.in(:hectare)
        total_area_to_s = (area.value * 10_000).to_f.floor.to_s.rjust(6, '0')
        [[total_area_to_s[0..-5], Onoma::Unit[:hectare].symbol],
         [total_area_to_s[-4, 2], Onoma::Unit[:are].symbol],
         [total_area_to_s[-2, 2], "ca"]].map(&:join).join(' ')
      },
      short_form_unit: lambda { |measure| "#{measure.value.to_f} #{measure.symbol}" }
    }.freeze

    def to_s(format = :default)
      if formatter = MEASURE_FORMATS[format]
        if formatter.respond_to?(:call)
          formatter.call(self).to_s
        else
          format(formatter, @value)
        end
      else
        inspect
      end
    end
  end
end
