((E, $) ->
  E.Events ||= {}
  E.Events.Map = {}
  E.Events.Map.initializing = "ekylibre:map:events:initializing"
  E.Events.Map.ready = "ekylibre:map:events:ready"
  E.Events.Map.new = {}
  E.Events.Map.new.start = "ekylibre:map:events:new:start"
  E.Events.Map.new.complete = "ekylibre:map:events:new:complete"
  E.Events.Map.new.cancel = "ekylibre:map:events:new:cancel"
  E.Events.Map.new.change = "ekylibre:map:events:new:change"
  E.Events.Map.shapeDraw = {}
  E.Events.Map.shapeDraw.start = "ekylibre:map:events:shapeDraw:start"
  E.Events.Map.shapeDraw.draw = "ekylibre:map:events:shapeDraw:draw"
  E.Events.Map.shapeDraw.edit = "ekylibre:map:events:shapeDraw:edit"
  E.Events.Map.shapeDraw.warn = "ekylibre:map:events:shapeDraw:warn"
  E.Events.Map.split = {}
  E.Events.Map.split.start = "ekylibre:map:events:split:start"
  E.Events.Map.split.complete = "ekylibre:map:events:split:complete"
  E.Events.Map.split.cancel = "ekylibre:map:events:split:cancel"
  E.Events.Map.split.change = "ekylibre:map:events:split:change"
  E.Events.Map.split.select = "ekylibre:map:events:split:select"
  E.Events.Map.split.cutting = "ekylibre:map:events:split:cutting"
  E.Events.Map.edit = {}
  E.Events.Map.edit.start = "ekylibre:map:events:edit:start"
  E.Events.Map.edit.complete = "ekylibre:map:events:edit:complete"
  E.Events.Map.edit.cancel = "ekylibre:map:events:edit:cancel"
  E.Events.Map.edit.change = "ekylibre:map:events:edit:change"
  E.Events.Map.select = {}
  E.Events.Map.select.select = "ekylibre:map:events:select:select"
  E.Events.Map.select.unselect = "ekylibre:map:events:select:unselect"
  E.Events.Map.select.over = "ekylibre:map:events:select:over"
  E.Events.Map.select.out = "ekylibre:map:events:select:out"

  class E.Map
    constructor: (@el, options = {})  ->
      $(@el).trigger E.Events.Map.initializing
      @_cartography = new Cartography.Map @el, options
      @initHooks()
      @initControls()
      
      this.displayCviCadastralPlants()
      this.displayCadastralLandParcelZone()

    initHooks: ->
      $(@_cartography.map).on Cartography.Events.new.start, ->
        $(document).trigger E.Events.Map.new.start

      $(@_cartography.map).on Cartography.Events.new.complete, (e) ->
        $(document).trigger E.Events.Map.new.complete, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.new.cancel, ->
        $(document).trigger E.Events.Map.new.cancel

      $(@_cartography.map).on Cartography.Events.new.change, ->
        $(document).trigger E.Events.Map.new.change

      $(@_cartography.map).on Cartography.Events.split.start, ->
        $(document).trigger E.Events.Map.split.start

      $(@_cartography.map).on Cartography.Events.split.complete, (e) ->
        $(document).trigger E.Events.Map.split.complete, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.split.cancel, ->
        $(document).trigger E.Events.Map.split.cancel

      $(@_cartography.map).on Cartography.Events.shapeDraw.start, ->
        $(document).trigger E.Events.Map.shapeDraw.start

      $(@_cartography.map).on Cartography.Events.shapeDraw.draw, (e) ->
        $(document).trigger E.Events.Map.shapeDraw.draw, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.shapeDraw.edit, (e) ->
        $(document).trigger E.Events.Map.shapeDraw.edit, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.shapeDraw.warn, (e) ->
        $(document).trigger E.Events.Map.shapeDraw.warn, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.split.change, (e) ->
        $(document).trigger E.Events.Map.split.change, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.split.select, (e) ->
        $(document).trigger E.Events.Map.split.select, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.split.cutting, (e) ->
        $(document).trigger E.Events.Map.split.cutting, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.edit.change, (e) ->
        $(document).trigger E.Events.Map.edit.change, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.select.select, (e) ->
        $(document).trigger E.Events.Map.select.select, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.select.unselect, (e) ->
        $(document).trigger E.Events.Map.select.unselect, e.originalEvent.data

      $(@_cartography.map).on Cartography.Events.select.selected, (e) ->
        $(document).trigger E.Events.Map.select.selected, e.originalEvent.data

      $(@_cartography.map).on 'moveend', (e) =>
        localStorage.setItem('bounds', @boundingBox())

      $(document).on 'ekylibre:db:synced', =>
        @sync(center:true)

      $(document).on 'ekylibre:timeslider:change', (e, date, callback) =>
        @sync(center:false, callback: callback)

      $(document).on 'drawer:opened', (e) =>
        drawerWidth = $(e.target).width()
        @setOffset(drawerWidth / 2)

      $(document).on 'drawer:closed', () =>
        @resetOffset()

      $(document).on 'ekylibre:db:ready', =>
        E.db.sync onsuccess: (e) =>
          @sync(center: true)

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
                cadastral_ref = layer.feature.properties.cadastral_ref
                layer._ghostIcon = new L.GhostIcon html: cadastral_ref, className: "simple-label blue", iconSize: [60, 40]
                layer._ghostMarker = L.marker(layer.getCenter(), icon: layer._ghostIcon)
                layer._ghostMarker.addTo layer._map

            layer.setStyle(color: "#C5D4F0", fillOpacity: 0, opacity: 1, fill: false)
            insertionMarker()

            layer._map.on 'zoomend', ->
              if !layer._ghostMarker and layer._map.getZoom() >= 16
                insertionMarker()
              if layer._ghostMarker and layer._map.getZoom() < 16
                layer._map.removeLayer layer._ghostMarker
                delete layer._ghostMarker

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

    setOffset: (x = 0, y = 0) ->
      @_cartography.setOffset x: x, y: y

    resetOffset: ->
      @_cartography.resetOffset()

    center: ->
      @_cartography.center.apply @_cartography, arguments

    highlight: ->
      @_cartography.highlight.apply @_cartography, arguments

    unhighlight: ->
      @_cartography.unhighlight.apply @_cartography, arguments

    select: ->
      @_cartography.select.apply @_cartography, arguments

    selectMany: ->
      @_cartography.selectMany.apply @_cartography, arguments

    unselectMany: ->
      @_cartography.unselectMany.apply @_cartography, arguments

    centerLayer: ->
      @_cartography.centerLayer.apply @_cartography, arguments

    centerCollection: ->
      @_cartography.centerCollection.apply @_cartography, arguments

    setView: ->
      @_cartography.setView.apply @_cartography, arguments

    unselect: ->
      @_cartography.unselect.apply @_cartography, arguments

    destroy: ->
      @_cartography.destroy.apply @_cartography, arguments

    edit: ->
      @_cartography.edit.apply @_cartography, arguments

    getMode: ->
      @_cartography.getMode.apply @_cartography, arguments

    setMode: ->
      @_cartography.setMode.apply @_cartography, arguments

    addControl: ->
      @_cartography.addControl.apply @_cartography, arguments

    removeControl: ->
      @_cartography.removeControl.apply @_cartography, arguments

    clean: ->
      @_cartography.clean()

    buildControls: ->
      @_cartography.buildControls.apply @_cartography, arguments

    destroyControls: ->
      @_cartography.destroyControls.apply @_cartography, arguments

    difference: ->
      @_cartography.difference.apply @_cartography, arguments

    union: ->
      @_cartography.union.apply @_cartography, arguments

    contains: ->
      @_cartography.contains.apply @_cartography, arguments

    intersect: ->
      @_cartography.intersect.apply @_cartography, arguments


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

      @_cartography.map.on 'moveend', @displayCviCadastralPlants
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



) ekylibre, jQuery
