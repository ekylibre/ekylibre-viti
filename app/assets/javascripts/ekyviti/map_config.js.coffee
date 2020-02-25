((E, $) ->
  
  E.cvi_land_parcels_onEachFeature = (layer) ->
    if  layer.feature.properties.updated
      layer.bringToFront()
      color = "#E7E8C0"
      klass = 'yellow'
    else
      layer.bringToBack()
      color = "#C5D4F0"
      klass = 'blue'

    insertionMarker = () ->
      if layer._map and layer._map.getZoom() >= 16 
        positionLatLng = layer.getCenter()
        centerPixels = layer._map.latLngToLayerPoint(positionLatLng)
        name = layer.feature.properties.name
        matchnameIndex =name.match(/-(\d{2}$)/)
        if matchnameIndex
          nameIndex = parseInt(matchnameIndex[1])
          offset = L.point(0, (nameIndex - 1) * layer._map.getZoom())
          positionLatLng = layer._map.layerPointToLatLng(centerPixels.add(offset))

        name = layer.feature.properties.name
        layer._ghostIcon = new L.GhostIcon html: name, className: "simple-label #{klass}", iconSize: [70, 40]
        layer._ghostMarker = L.marker(positionLatLng, icon: layer._ghostIcon)
        layer._ghostMarker.addTo layer._map
        
    style = { color: color, fillOpacity: 0, opacity: 1, fill: true }
   
    insertionMarker()
    layer.setStyle(style)

    layer._map.on 'zoomend', ->
      if layer._ghostMarker
        layer._map.removeLayer layer._ghostMarker
        delete layer._ghostMarker
      insertionMarker()

    layer.on 'remove', (e) ->
      if layer._ghostMarker
        layer._map.removeLayer layer._ghostMarker
        delete layer._ghostMarker
  
  E.cvi_cadastral_plants_onEachFeature = (layer) ->
    insertionMarker = () ->
      if layer._map.getZoom() >= 16
        positionLatLng = layer.getCenter()
        centerPixels = layer._map.latLngToLayerPoint(positionLatLng)
        cadastralRef = layer.feature.properties.cadastral_ref
        matchCadastralRefIndex = cadastralRef.match(/-(\d{2}$)/)
        if matchCadastralRefIndex
          cadastralRefIndex = parseInt(matchCadastralRefIndex[1])
          offset = L.point(0, (cadastralRefIndex - 1) * layer._map.getZoom())
          positionLatLng = layer._map.layerPointToLatLng(centerPixels.add(offset))

        cadastral_ref = layer.feature.properties.cadastral_ref
        layer._ghostIcon = new L.GhostIcon html: cadastral_ref, className: "simple-label blue", iconSize: [70, 40]
        layer._ghostMarker = L.marker(positionLatLng, icon: layer._ghostIcon)
        layer._ghostMarker.addTo layer._map

    layer.setStyle(color: "#C5D4F0", fillOpacity: 0, opacity: 1, fill: false)
    insertionMarker()
      
    layer._map.on 'zoomend', ->
      if layer._ghostMarker
        layer._map.removeLayer layer._ghostMarker
        delete layer._ghostMarker
      insertionMarker()

    layer.on 'remove', (e) ->
      if layer._ghostMarker
        layer._map.removeLayer layer._ghostMarker
        delete layer._ghostMarker

  E.cvi_cultivable_zones_onEachFeature = (layer) ->
    if layer.feature.properties.status == 'created'
      color = '#000000'
    else
      color = "#C5D4F0"
    insertionMarker = () ->
      if layer._map.getZoom() >= 16
        name = layer.feature.properties.name
        layer._ghostIcon = new L.GhostIcon html: name, className: "simple-label white", iconSize: [60, 40]
        layer._ghostMarker = L.marker(layer.getCenter(), icon: layer._ghostIcon)
        layer._ghostMarker.addTo layer._map

    layer.setStyle(color: color, fillOpacity: 0.3, opacity: 1, fill: true)
    insertionMarker()

    layer._map.on 'zoomend', ->
      if layer._ghostMarker
        layer._map.removeLayer layer._ghostMarker
        delete layer._ghostMarker
      insertionMarker()

    layer.on 'remove', (e) ->
      if layer._ghostMarker
        layer._map.removeLayer layer._ghostMarker
        delete layer._ghostMarker

) ekylibre, jQuery