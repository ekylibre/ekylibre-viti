((E, $) ->


  class E.CviMap extends E.Map
    constructor: (@el, options = {})  ->
      super @el, options
      @initControls()
      @configMap()
      @displayCadastralLandParcelZone()
      @firstLoad = true

    initControls: ->
      editLayer = @_cartography.getOverlay('edition')
      layersControl =   @_cartography.controls.get('layers').getControl()
      layersControl.removeLayer(editLayer)
    
    #TODO: move to cartography
    configMap: ->
      @ghostLabelCluster = L.ghostLabelCluster {type: 'number', innerClassName: 'leaflet-ghost-label-collapsed', margin: -3 }
      @ghostLabelCluster.addTo @_cartography.getMap()
      ghostIconPane = @_cartography.getMap().createPane('ghost-icon')
      ghostIconPane.style.zIndex = 6
      makerPane = @_cartography.getMap().getPane('markerPane')
      makerPane.style.zIndex = 1000
    
    displayCadastralLandParcelZone: (visible = true) =>

      return if @_cadastralLandParcelZoneLoading

      @_cartography.map.on 'moveend', @displayCadastralLandParcelZone

      if @getZoom() < 17 and @_cartography.getOverlay('cadastral_land_parcel_zones')
        cadastralZonesLayer = E.map._cartography.getFeatureGroup(name: 'cadastral_land_parcel_zones')
        for layer in cadastralZonesLayer.getLayers()
          layer.selected = false
        @_cartography.removeOverlay('cadastral_land_parcel_zones')

      if @getZoom() >= 17
        selectedIds = $('.map').data('selected-ids') || []
        selectedIdsParams = if selectedIds && selectedIds.length > 0 then "&selected_ids=#{selectedIds}" else ""
        url = '/backend/cadastral_land_parcel_zones' + "?bounding_box=#{@boundingBox()}" + selectedIdsParams

        onSuccess = (data) =>
          onEachFeature = (feature, layer) =>

            insertionMarker = () ->
              cadastral_ref = layer.feature.properties.cadastral_ref
              layer._ghostIcon = new L.GhostIcon html: cadastral_ref, className: "simple-label white", iconSize: [40, 40]
              layer._ghostMarker = L.marker(layer.getCenter(), icon: layer._ghostIcon, pane: 'ghost-icon')

              layer._ghostMarker.addTo layer._map
              layer.addTo layer._map
              layer.bringToBack()

            layer.on 'add', (e) ->
              insertionMarker()

            layer.on 'remove', (e) ->
              if layer._ghostMarker
                layer._map.removeLayer layer._ghostMarker

          style = (feature) ->
            color: '#ffffff', fillOpacity: 0, opacity: 1, dashArray: '6, 6',weight:1

          cadastralZonesSerie = [{cadastral_land_parcel_zones: data}, [name: 'cadastral_land_parcel_zones', label: I18n.t( 'front-end.labels.cadastral_land_parcel_zones'), type: 'simple', index: true, serie: 'cadastral_land_parcel_zones', onEachFeature: onEachFeature, style: style]]

          @_cartography.addOverlay(cadastralZonesSerie) if @getZoom() >= 17

        @asyncLoading(url, onSuccess, 'cadastralLandParcelZone' )

  $.loadMap = ->
    return unless $("*[data-cvi-cartography]").length
    $el = $("*[data-cvi-cartography]").first()
    opts = $el.data("cvi-cartography")
    E.map = new E.CviMap($el[0], opts)

  $.reloadMap = (keepBounds = true ) ->
    map = E.map
    currentBounds = map.getBounds() if keepBounds
    $(map.el.children).remove()
    $.loadMap()
    E.map.fitBounds(currentBounds) if keepBounds

  $(document).ready $.loadMap

  $(document).on E.Events.Map.ready, "*[data-cvi-cartography]", (e) ->
    $(e.target).css('visibility', 'visible')

  $(document).on E.Events.Map.ready, ->
    if E.map.firstLoad
      E.map._cartography.setView()

) ekylibre, jQuery
