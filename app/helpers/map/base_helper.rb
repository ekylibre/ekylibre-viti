module Map
  module BaseHelper
    def map_config(options = {})
      {
        box: {
          width: '100%',
          height: '100%'
        },
        backgrounds: backgrounds,
        defaultCenter: {
          lat: 46.74738913515841,
          lng: 2.493896484375
        }
      }.merge options
    end

    def backgrounds
      MapLayer.available_backgrounds.map { |e| e.attributes.transform_keys { |k| k.camelize(:lower) } }
    end
  end
end
