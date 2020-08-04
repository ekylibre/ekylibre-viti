module Cartography
  module CartographyHelper
    def cvi_cartography(options = {}, html_options = {}, &block)
      config = configure_cartography(options, &block)
      content_tag(:div, nil, html_options.deep_merge(data: { 'cvi-cartography': config.to_json }))
    end
  end
end
