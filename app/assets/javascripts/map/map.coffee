((E, $) ->
  E.Events ||= {}
  E.Events.Map = {}
  E.Events.Map.initializing = "ekylibre:map:events:initializing"
  E.Events.Map.ready = "ekylibre:map:events:ready"

  class E.Map
    constructor: (@el, options = {})  ->
      $(@el).trigger E.Events.Map.initializing
      @_cartography = new Cartography.Map @el, options
      @initControls()
      this.displayCviCadastralPlants()
      this.displayCadastralLandParcelZone()
      @firstLoad = true

    initControls: ->
      @removeControl('edit')

    onSync: =>
      if arguments[arguments.length-1].constructor.name is 'Function'
        args = arguments[0]
        callback = arguments[arguments.length-1]
      else
        args = arguments

      layerName = args[1]

      if @getMode() == "productions-index"
        if layerName is 'cvi_cadastral_plants'
          onEachFeature = (layer) ->
            insertionMarker = () ->
              if layer._map.getZoom() >= 16
                positionLatLng = layer.getCenter()
                centerPixels = layer._map.latLngToLayerPoint(positionLatLng)
                cadastralRef = layer.feature.properties.cadastral_ref
                matchCadastralRefIndex = cadastralRef.match(/-(\d$)/)
                if matchCadastralRefIndex
                  cadastralRefIndex = matchCadastralRefIndex[1]
                  offset = L.point(0, (cadastralRefIndex - 1) * layer._map.getZoom())
                  positionLatLng = layer._map.layerPointToLatLng(centerPixels.add(offset))

                cadastral_ref = layer.feature.properties.cadastral_ref
                layer._ghostIcon = new L.GhostIcon html: cadastral_ref, className: "simple-label blue", iconSize: [60, 40]
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

      [].push.call args, onEachFeature: onEachFeature

      @_cartography.sync.apply @, args

      callback.call @, args if callback
      $(document).trigger E.Events.Map.ready
      $(@el).trigger E.Events.Map.ready

    _cviCadastralPlantsPath: ->
      $(@el).data('cvi-cadastral-plants-path')

    getZoom: ->
      @_cartography.map.getZoom()

    boundingBox: ->
      @_cartography.map.getBounds().toBBoxString()

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

      if @getZoom() < 16 and @_cartography.getOverlay('cadastral_land_parcel_zones')
        cadastralZonesLayer = E.map._cartography.getFeatureGroup(name: 'cadastral_land_parcel_zones')
        for layer in cadastralZonesLayer.getLayers()
          layer.selected = false
        @_cartography.removeOverlay('cadastral_land_parcel_zones')

      if @getZoom() >= 16
        selectedIds = $('.map').data('selected-ids') || []
        selectedIdsParams = if selectedIds && selectedIds.length > 0 then "&selected_ids=#{selectedIds}" else ""
        url = '/backend/cadastral_land_parcel_zones' + "?bounding_box=#{@boundingBox()}" + selectedIdsParams

        onSuccess = (data) =>
          onEachFeature = (feature, layer) =>

            insertionMarker = () ->
              cadastral_ref = layer.feature.properties.cadastral_ref
              layer._ghostIcon = new L.GhostIcon html: cadastral_ref, className: "simple-label white", iconSize: [40, 40]
              layer._ghostMarker = L.marker(layer.getCenter(), icon: layer._ghostIcon)

              layer._ghostMarker.addTo layer._map
              layer.addTo layer._map

            layer.on 'add', (e) ->
              insertionMarker()

            layer.on 'remove', (e) ->
              if layer._ghostMarker
                layer._map.removeLayer layer._ghostMarker

          style = (feature) ->
            color: '#ffffff', fillOpacity: 0, opacity: 1, dashArray: '6, 6',weight:1

          cadastralZonesSerie = [{cadastral_land_parcel_zones: data}, [name: 'cadastral_land_parcel_zones', label: "cadastral_land_parcel_zones", type: 'simple', index: true, serie: 'cadastral_land_parcel_zones', onEachFeature: onEachFeature, style: style]]

          @_cartography.addOverlay(cadastralZonesSerie)

        @asyncLoading(url, onSuccess, 'cadastralLandParcelZone' )

    displayCviCadastralPlants: (visible = true) =>

      return if @_cviCadastralPlantLoading

      @_cartography.map.on 'moveend', ->
        E.map.firstLoad = false
        @displayCviCadastralPlants
      url = @_cviCadastralPlantsPath()

      onSuccess = (data) =>
        @onSync( data, "cvi_cadastral_plants")

      @asyncLoading(url, onSuccess, 'cviCadastralPlant')

    asyncLoading: (url, onSuccess, resource_name) =>
      return unless url

      $.ajax
        method: 'GET'
        dataType: 'json'
        url: url
        beforeSend: =>
          @['_' + resource_name + 'Loading'] = true
        success: (data) =>
          onSuccess.call @, data
          @['_' + resource_name + 'Loading'] = false
        error: () =>
        complete: () =>

  $.loadMap = ->
    return unless $("*[data-cartography]").length
    $el = $("*[data-cartography]").first()
    mapAlreadyInitialized = $("*[data-cartography]").data('map-id') is null or $("*[data-cartography]").data('map-id')?
    return if mapAlreadyInitialized
    opts = $el.data("cartography")

    opts.bounds = bounds if bounds = localStorage.getItem("bounds")

    E.map = new E.Map($el[0], opts)

  $(document).ready $.loadMap

  $(document).on E.Events.Map.ready, "*[data-cartography]", (e) ->
    $(e.target).css('visibility', 'visible')

  $(document).on E.Events.Map.ready, ->
    if E.map.firstLoad
      E.map._cartography.setView()

) ekylibre, jQuery
