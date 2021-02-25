module Map
  module BaseHelper
    def carto_map_options(options = {}, html_options = {}, data_attribute_name = 'cartography-map', &block)
      config = configure_cartography(options, &block)
      html_options.deep_merge(data: { "#{data_attribute_name}": config.to_json })
    end

    def cvi_map(&block)
      config = configure_cartography(map_config(mode: 'productions-index',
                                                controls: { zoom: true,
                                                            fullscreen: true,
                                                            layers: true },
                                                controlLayers: { addToMap: true }), &block)
      content_tag(:div, nil, { class: 'map-fullwidth map-halfheight', data: { 'cvi-cartography': config.to_json } })
    end

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
