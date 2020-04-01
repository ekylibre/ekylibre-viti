((E, $) ->
  E.Events ||= {}
  E.Events.Map = {}
  E.Events.Map.initializing = "ekylibre:map:events:initializing"
  E.Events.Map.ready = "ekylibre:map:events:ready"
  E.Events.Map.edit = {}
  E.Events.Map.edit.change = "ekylibre:map:events:edit:change"
  E.Events.Map.split = {}
  E.Events.Map.split.change = "ekylibre:map:events:split:change"

  class E.Map
    constructor: (@el, options = {})  ->
      $(@el).trigger E.Events.Map.initializing
      @_cartography = new Cartography.Map @el, options
      @initHooks()
      @initControls()
      @configMap()
      @asyncLayersLoading()
      @displayCadastralLandParcelZone()
      @firstLoad = true

    #TODO: move to cartography
    configMap: ->
      @ghostLabelCluster = L.ghostLabelCluster {type: 'number', innerClassName: 'leaflet-ghost-label-collapsed', margin: -3 }
      @ghostLabelCluster.addTo @_cartography.getMap()
      ghostIconPane = @_cartography.getMap().createPane('ghost-icon')
      ghostIconPane.style.zIndex = 6
      makerPane = @_cartography.getMap().getPane('markerPane')
      makerPane.style.zIndex = 1000

    asyncLayersLoading: ->
      asyncLayers = @_cartography.options.layers.filter (layer) -> layer.asyncUrl?
      for asyncLayer in asyncLayers
        onSuccess = (data) =>
          @onSync(data, asyncLayer.name)
        @asyncLoading(asyncLayer.asyncUrl, onSuccess)

    initHooks: ->
      $(@_cartography.map).on Cartography.Events.edit.change, (e) ->
        $(document).trigger E.Events.Map.edit.change, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.split.change, (e) ->
          $(document).trigger E.Events.Map.split.change, e.originalEvent.data

    initControls: ->
      @removeControl('edit')
      editLayer = @_cartography.getOverlay('edition')
      layersControl =   @_cartography.controls.get('layers').getControl()
      layersControl.removeLayer(editLayer)
      @_cartography.controls.get('layers').getControl().addTo(@_cartography.getMap())

    onSync: =>
      if arguments[arguments.length-1].constructor.name is 'Function'
        args = arguments[0]
        callback = arguments[arguments.length-1]
      else
        args = arguments

      layerName = args[1]

      onEachFeature = E["#{layerName}_onEachFeature"]

      [].push.call args, onEachFeature: onEachFeature

      @_cartography.sync.apply @, args

      callback.call @, args if callback
      $(document).trigger E.Events.Map.ready
      $(@el).trigger E.Events.Map.ready

    addControl: ->
      @_cartography.addControl.apply @_cartography, arguments

    getZoom: ->
      @_cartography.map.getZoom()

    boundingBox: ->
      @_cartography.map.getBounds().toBBoxString()

    getBounds: ->
      @_cartography.map.getBounds()
    
    fitBounds: (bounds) ->
      @_cartography.map.fitBounds(bounds)

    edit: ->
      @_cartography.edit.apply @_cartography, arguments

    select: ->
      @_cartography.select.apply @_cartography, arguments

    setView: ->
      @_cartography.setView.apply @_cartography, arguments

    getMode: ->
      @_cartography.getMode.apply @_cartography, arguments

    centerLayer: ->
      @_cartography.centerLayer.apply @_cartography, arguments

    removeControl: ->
      @_cartography.removeControl.apply @_cartography, arguments

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

    asyncLoading: (url, onSuccess) =>
      return unless url

      $.ajax
        method: 'GET'
        dataType: 'json'
        url: url
        beforeSend: =>
        success: (data) =>
          onSuccess.call @, data
        error: () =>
        complete: () =>

  $.loadMap = ->
    return unless $("*[data-cvi-cartography]").length
    $el = $("*[data-cvi-cartography]").first()
    opts = $el.data("cvi-cartography")
    E.map = new E.Map($el[0], opts)

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
