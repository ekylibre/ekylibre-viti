(($) ->
  "use strict"

  $.fn.mapsFromData = ->
    $(this).each ->
      mapElement = $(this)
      options = {}
      map = {}
      if mapElement.prop("mapLoaded") isnt true
        options = mapElement.data("map")

        # Box
        if options.box
          mapElement.height options.box.height  if options.box.height
          mapElement.width options.box.width  if options.box.width
        mapElement.css display: "block"
        map = Leaflet.map(mapElement[0],
          maxZoom: 25
          scrollWheelZoom: false
          zoomControl: false
          attributionControl: true
        )
        mapElement.prop("map", map)
        if options.background?
          opts['attribution'] = options.background.attribution if options.background.attribution?
          opts['minZoom'] = options.background.minZoom if options.background.minZoom?
          opts['maxZoom'] = options.background.maxZoom if options.background.maxZoom?
          opts['subdomains'] = options.background.subdomains if options.background.subdomains?
          Leaflet.tileLayer(options.background.url, opts).addTo map
        else
          # Add an OpenStreetMap tile layer
          Leaflet.tileLayer.provider("OpenStreetMap.HOT").addTo map

        $.each options.geometries, (index, value) ->
          layer = undefined
          if value.shape
            layer = Leaflet.GeoJSON.geometryToLayer(value.shape).setStyle(weight: 2)
            if value.url
              layer.on "click", (e) ->
                window.location.assign value.url
                return

            layer.addTo map
          return

        # # Zoom
        # map.addControl Leaflet.control.zoom(
        #   position: "topleft"
        #   zoomInText: ""
        #   zoomOutText: ""
        # )
        # Scale
        map.addControl new Leaflet.Control.Scale(
          imperial: false
          maxWidth: 200
        )

        # Bounding box
        map.fitBounds Leaflet.latLngBounds(options.view.boundingBox)  if options.view and options.view.boundingBox

        mapElement.prop "mapLoaded", true
      return

    return

  $.loadLeafletMaps = ->
    $("*[data-map]").mapsFromData()
    return

  $(document).ready $.loadLeafletMaps
  $(document).on "page:load cocoon:after-insert cell:load", $.loadMaps

  true
) jQuery
