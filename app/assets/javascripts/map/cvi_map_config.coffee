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

    addLabel = () ->
      debugger
      positionLatLng = layer.getCenter()
      centerPixels = layer._map.latLngToContainerPoint(positionLatLng)
      name = layer.feature.properties.name
      matchnameIndex = name.match(/-(\d*$)/)
      if matchnameIndex
        nameIndex = parseInt(matchnameIndex[1])
        offset = L.point(0, (nameIndex - 1) * 1.1 * layer._map.getZoom())
        positionLatLng = layer._map.containerPointToLatLng(centerPixels.add(offset))
      name = "#{layer.feature.properties.name} | #{layer.feature.properties.vine_variety} | #{layer.feature.properties.year}"
      layer.label = new L.GhostLabel( { baseClassName: '', className: "simple-label #{klass}", pane: 'ghost-icon' } ).setContent(name).setLatLng(positionLatLng)
              
    style = { color: color, fillOpacity: 0, opacity: 1, fill: true, weight: 2 }
   
    layer.setStyle(style)

    handleLabels = () ->
      return unless layer._map
      if layer._map.getZoom() == 16
        layer.label.removeFrom(layer._map) if layer.label
        E.map.ghostLabelCluster.removeLayer target: { label: layer.label } unless layer.label is undefined
        addLabel()
        E.map.ghostLabelCluster.bind layer.label, layer
        E.map.ghostLabelCluster.refresh()
        return
      if layer._map.getZoom() < 16
        E.map.ghostLabelCluster.refresh()
      if layer._map.getZoom() >= 17 
        layer.label.removeFrom(layer._map) if layer.label
        E.map.ghostLabelCluster.removeLayer target: { label: layer.label } unless layer.label is undefined
        E.map.ghostLabelCluster.refresh()
        addLabel()
        layer.label.addTo(layer._map)


    layer._map.on 'zoomend', handleLabels

    layer.on 'remove', ->
      E.map.ghostLabelCluster.removeLayer target: { label: layer.label } unless layer.label is undefined
      E.map.ghostLabelCluster.refresh()

    layer.on 'add', ->
      E.map.ghostLabelCluster.bind layer.label, layer unless layer.label is undefined
      E.map.ghostLabelCluster.refresh()

  E.cvi_cadastral_plants_onEachFeature = (layer) ->
    insertionMarker = () ->
      if layer._map.getZoom() >= 16
        positionLatLng = layer.getCenter()
        centerPixels = layer._map.latLngToLayerPoint(positionLatLng)
        cadastralRef = layer.feature.properties.cadastral_ref
        matchCadastralRefIndex = cadastralRef.match(/-(\d*$)/)
        if matchCadastralRefIndex
          cadastralRefIndex = parseInt(matchCadastralRefIndex[1])
          offset = L.point(0, (cadastralRefIndex - 1) * layer._map.getZoom())
          positionLatLng = layer._map.layerPointToLatLng(centerPixels.add(offset))

        cadastral_ref = layer.feature.properties.cadastral_ref
        layer._ghostIcon = new L.GhostIcon html: cadastral_ref, className: "simple-label blue", iconSize: [70, 40]
        layer._ghostMarker = L.marker(positionLatLng, icon: layer._ghostIcon, pane: 'ghost-icon')
        layer._ghostMarker.addTo layer._map

    layer.setStyle(color: "#C5D4F0", fillOpacity: 0, opacity: 1, fill: false, weight: 2)
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
        layer._ghostMarker = L.marker(layer.getCenter(), icon: layer._ghostIcon, pane: 'ghost-icon')
        layer._ghostMarker.addTo layer._map

    layer.setStyle(color: color, fillOpacity: 0.3, opacity: 1, fill: true, weight: 2)
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