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
      debugger
      @_cartography = new Cartography.Map @el, options
      @initHooks()
      @initControls()
      
      # E.db.sync onsuccess: (e) =>
      #   @sync(center:true)


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
        @setOffset(drawerWidth/2)

      $(document).on 'drawer:closed', () =>
        @resetOffset()

      $(document).on 'ekylibre:db:ready', =>
        E.db.sync onsuccess: (e) =>
          @sync(center:true)

    initControls: ->
      @removeControl('edit')

    sync: (options = {})->
      date = new Date $('.timeslider-slider').first().data('slider').getValue()
      if @getMode() == "plots-edit" || @getMode() == "plots-cut"
        E.db.plots.allOn date, onsuccess: =>
          callback = () =>
            @_cartography.setView() if options.center
            options.callback.apply @ if options.callback
          @onSync.apply @, [arguments, callback]

      else if @getMode() == "productions-edit"
        E.db.plots.allOn date, onsuccess:  =>
          callback = () =>
            E.db.crops.allOn date, onsuccess: =>
              callback = () =>
                @_cartography.setView() if options.center

              @onSync.apply @, [[[], "crops"], callback]
          @onSync.apply @, [arguments, callback]

      else if @getMode() is "interventions-new" or @getMode() is "productions-index"
        E.db.crops.allOn date, onsuccess: =>
          callback = () =>
            @_cartography.setView() if options.center
          @onSync.apply @, [arguments, callback]

    onSync: =>
      if arguments[arguments.length-1].constructor.name is 'Function'
        args = arguments[0]
        callback = arguments[arguments.length-1]
      else
        args = arguments

      layerName = args[1]

      if @getMode() is "plots-edit" and layerName is "plots"
        onEachFeature = (layer) ->
          L.DomUtil.addClass(layer._path, "leaflet-no-pointer")

          onMouseOver = (e) ->
            $(document).trigger E.Events.Map.select.over, uuid: e.target.feature.properties.uuid

          onMouseOut = (e) ->
            $(document).trigger E.Events.Map.select.out, uuid: e.target.feature.properties.uuid

          layer.on 'mouseover', onMouseOver, @
          layer.on 'mouseout', onMouseOut, @

          layer.on 'remove', (e) =>
            layer.off 'mouseover', onMouseOver, @
            layer.off 'mouseout', onMouseOut, @

      if @getMode() is "plots-cut" and layerName is "plots"
        onEachFeature = (layer) =>
          layer._controls ||= {}
          layer.options.selecting = className: "leaflet-selected-plot"

          L.DomUtil.addClass(layer._path, "leaflet-no-pointer")

          latlng = layer.polylabel()

          removeCutMarker = () =>
            return unless layer._controls.cutMarker
            layer._map.removeLayer layer._controls.cutMarker
            layer._controls.cutMarker.off 'click'
            delete layer._controls.cutMarker

          cutMarker = () =>
            removeCutMarker()
            return unless layer._map
            pt = layer._map.latLngToContainerPoint(latlng)
            layer._cutIcon = new L.GhostIcon className: "ghost-icon cut-ghost-icon", iconSize: [40, 40]

            offset = 0
            cutPt = L.point([pt.x + offset/2, pt.y])
            cutLatLng = layer._map.containerPointToLatLng cutPt

            layer._controls.cutMarker = L.marker(cutLatLng, icon: layer._cutIcon)
            layer._controls.cutMarker.addTo layer._map

            layer._controls.cutMarker.on 'click', (e) =>
              for l in @_cartography.getFeatureGroup().getLayers()
                continue unless l._controls.cutMarker
                @_cartography.map.removeLayer l._controls.cutMarker
                l._controls.cutMarker.off 'click'
                delete l._controls.cutMarker
              layer.options.selected = true
              @addControl('shape_cut')
              @_cartography.controls.get('shape_cut').getControl()._handler.activate(layer.feature.properties.uuid)

          _on_add = () =>
            return if layer.options.initialized
              layer.options.initialized = true
            selectedLayers = @_cartography.getFeatureGroup().getLayers().filter (l) ->
                              l.options.selected == true
            cutMarker() unless selectedLayers.length > 0

          layer.on 'add', _on_add, @

      if @getMode() == "productions-edit"
        if layerName is "plots"

          onEachFeature = (layer) =>
            layer._controls = {}
            gutter = 5
            layer.options.selecting = className: "leaflet-selected-plot"

            L.DomUtil.addClass(layer._path, "leaflet-no-pointer")

            latlng = layer.polylabel()

            removeInsertionMarker = () =>
              return unless layer._controls.selectMarker
              layer._map.removeLayer layer._controls.selectMarker
              layer._controls.selectMarker.off 'click'
              delete layer._controls.selectMarker
              L.DomUtil.removeClass(layer._path, "leaflet-layer-editable")

            deletionMarker = () ->
              removeInsertionMarker()
              pt = layer._map.latLngToContainerPoint(latlng)
              className = 'ghost-icon deletion-ghost-icon'
              layer._selectIcon = new L.GhostIcon className: className, iconSize: [40, 40]
              offset = layer._selectIcon.options.iconSize[0] + gutter
              newPt = L.point([pt.x - offset/2, pt.y])
              newLatLng = layer._map.containerPointToLatLng newPt


              layer._controls.selectMarker = L.marker(newLatLng, icon: layer._selectIcon)
              layer._controls.selectMarker.addTo layer._map

              layer._controls.selectMarker.on 'click', (e) ->
                layer.fire 'select'
                insertionMarker()
                cutMarker()

            insertionMarker = () ->
              removeInsertionMarker()
              return unless layer._map
              pt = layer._map.latLngToContainerPoint(latlng)
              className = 'ghost-icon insertion-ghost-icon'
              layer._selectIcon = new L.GhostIcon className: className, iconSize: [40, 40]
              offset = layer._selectIcon.options.iconSize[0] + gutter
              newPt = L.point([pt.x - offset/2, pt.y])
              newLatLng = layer._map.containerPointToLatLng newPt

              layer._controls.selectMarker = L.marker(newLatLng, icon: layer._selectIcon)
              layer._controls.selectMarker.addTo layer._map

              L.DomUtil.addClass(layer._path, "leaflet-layer-editable")
              layer._controls.selectMarker.on 'click', (e) ->
                layer.fire 'select'
                deletionMarker()

                removeCutMarker()

            removeCutMarker = () =>
              return unless layer._controls.cutMarker
              layer._map.removeLayer layer._controls.cutMarker
              layer._controls.cutMarker.off 'click'
              delete layer._controls.cutMarker

            cutMarker = () =>
              removeCutMarker()
              return unless layer._map
              pt = layer._map.latLngToContainerPoint(latlng)
              layer._cutIcon = new L.GhostIcon className: "ghost-icon cut-ghost-icon", iconSize: [40, 40]

              offset = layer._cutIcon.options.iconSize[0] + gutter
              cutPt = L.point([pt.x + offset/2, pt.y])
              cutLatLng = layer._map.containerPointToLatLng cutPt

              layer._controls.cutMarker = L.marker(cutLatLng, icon: layer._cutIcon)
              layer._controls.cutMarker.addTo layer._map

              layer._controls.cutMarker.on 'click', (e) =>
                layer.controls.enabled = false
                @addControl('shape_cut')
                @_cartography.controls.get('shape_cut').getControl()._handler.activate(layer.feature.properties.uuid)

            _on_add = () =>
              unless layer.options.initialized
                layer.onBuild() if layer.onBuild and layer.onBuild.constructor.name == 'Function'
                layer.options.initialized = true
              return unless layer.controls && layer.controls.enabled

              if layer.selected
                deletionMarker()
              else
                insertionMarker()
                cutMarker()

            uneditable = () ->
              layer.controls.enabled = false
              removeInsertionMarker()
              removeCutMarker()
              layer.fire 'unlock'
              layer.fire 'refresh'

            lock = (uuid, availableGeometries, lockedGeometries) ->
              plotsLayerGroup = E.map._cartography.getFeatureGroup(name: 'plots')
              cropsLayerGroup = E.map._cartography.getFeatureGroup(name: 'crops')

              E.map.unselect uuid
              layer.controls.enabled = false
              removeInsertionMarker()
              removeCutMarker()
              plotsLayerGroup.removeLayer(layer)

              for lockedGeometry in lockedGeometries
                cropsLayerGroup.addData lockedGeometry

              for availableGeometry in availableGeometries
                loo = plotsLayerGroup.addData availableGeometry
                plotsLayerGroup.getLayers()[..].pop().fire 'refresh'

              E.map.buildControls('crops')

            unlock = () ->
              layer.controls.enabled = true
              layer.fire 'unlock'

            layer.onBuild = () =>
              return unless uuid = layer.feature.properties.uuid
              plotsLayerGroup = E.map._cartography.getFeatureGroup(name: 'plots')
              layer.controls ||= {}

              E.db.crops.all (list) =>
                relevantCropsList = list.filter (crop) =>
                                      @intersect(layer.feature.geometry, crop.shape)

                return uneditable() unless $("body").data('mandatory-inputs-fill')

                [locked, lockedGeometries, availableGeometries] = E.map.isLocked(layer.feature, relevantCropsList)
                if locked
                  lock(uuid, availableGeometries, lockedGeometries)
                else
                  unlock()

                layer.fire 'refresh'


            _on_movestart = () =>
              removeInsertionMarker()
              removeCutMarker()

            _on_remove = () =>
              if layer.controls && layer.controls.enabled
                layer.controls.enabled = false

              removeInsertionMarker()
              removeCutMarker()

            layer._map.on 'moveend', _on_add, @
            layer.on 'add', _on_add, @
            layer.on 'refresh', _on_add, @

            layer.on 'remove', _on_remove, @
            layer._map.on 'movestart', _on_movestart, @

            layer.on L.Selectable.Event.Layer.UNSELECT, (e) ->
              insertionMarker()
              cutMarker()

        else if layerName is 'crops'
          onEachFeature = (layer) =>
            layer.options.locking = className: "leaflet-locked-plot"
            layer.feature.properties.color ||= "#1195F6"
            layer.setStyle color: layer.feature.properties.color, opacity: 1, fillColor: layer.feature.properties.color, fillOpacity: 0.5, weight: 3, color: "#fff"

            layer.on 'click', (e) =>
              layer.fire 'select'

            unlockable = () ->
              layerGroup = E.map._cartography.getFeatureGroup(name: 'crops')
              layerGroup.removeLayer layer

            _on_add = () =>
              unless layer.options.initialized
                layer.onBuild() if layer.onBuild and layer.onBuild.constructor.name == 'Function'
                layer.options.initialized = true

            layer.onBuild = () =>
              return unlockable() unless $("body").data('mandatory-inputs-fill')
              layer.fire 'lock', label: layer.feature.properties.label, wrapperClassName: 'leaflet-unavailable-plot'

            layer.on 'add', _on_add, @
            layer._map.on 'moveend', _on_add, @
            layer.on 'refresh', _on_add, @

            layer.on 'remove', (e) =>
              $(document).trigger E.Events.Map.select.unselect, uuid: layer.feature.properties.uuid

      if @getMode() == "interventions-new" || @getMode() == "productions-index"
        if layerName is 'crops'
          onEachFeature = (layer) =>
            layer.feature.properties.color ||= "#1195F6"
            layer.setStyle color: layer.feature.properties.color, opacity: 1, fillColor: layer.feature.properties.color, fillOpacity: 0.5, weight: 3, color: "#fff"

            layer.on 'click', (e) =>
              layer.fire 'select'

            layer.on 'remove', (e) =>
              $(document).trigger E.Events.Map.select.unselect, uuid: layer.feature.properties.uuid

      [].push.call args, onEachFeature: onEachFeature

      @_cartography.sync.apply @, args

      callback.call @, args if callback
      $(document).trigger E.Events.Map.ready
      $(@el).trigger E.Events.Map.ready

    _cropZonesPath: ->
      $(@el).data('crop-zones-path')

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


    displayRegisteredCropZones: (visible = true) =>
      console.error 'display', @getZoom()

      return if @_cropZonesLoading

      if visible
        $(document).on "ekylibre:db:synced", @displayRegisteredCropZones
        @_cartography.map.on 'moveend', @displayRegisteredCropZones
      else
        $(document).off "ekylibre:db:synced", @displayRegisteredCropZones
        @_cartography.map.off 'moveend', @displayRegisteredCropZones

      if !visible and @_cartography.getOverlay('crop_zones')
        @_cartography.map.off 'moveend', @displayRegisteredCropZones
        cropZonesLayer = E.map._cartography.getFeatureGroup(name: 'crop_zones')
        for layer in cropZonesLayer.getLayers()
          layer.selected = false
        @_cartography.removeOverlay('crop_zones')

      if @getZoom() < 16 and @_cartography.getOverlay('crop_zones')
        cropZonesLayer = E.map._cartography.getFeatureGroup(name: 'crop_zones')
        for layer in cropZonesLayer.getLayers()
          layer.selected = false
        @_cartography.removeOverlay('crop_zones')

      if visible and @getZoom() >= 16
        selectedIds = $('.map').data('selected-ids') || []
        selectedIdsParams = if selectedIds && selectedIds.length > 0 then "&selected_ids=#{selectedIds}" else ""
        url = @_cropZonesPath() + "?bounding_box=#{@boundingBox()}" + selectedIdsParams

        onSuccess = (data) =>
          E.map.backupSelectedIds = $('.map').data('selected-ids') || []
          onEachFeature = (feature, layer) =>

            deletionMarker = () =>
              className = 'ghost-icon deletion-ghost-icon'
              layer._ghostIcon = new L.GhostIcon className: className, iconSize: [40, 40]
              layer._ghostMarker = L.marker(layer.getCenter(), icon: layer._ghostIcon)
              layer._childLayer = @_cartography.getFeatureGroup(name: 'edition').getLayers().pop()

              layer._childLayer.on 'remove', (e) ->
                layer._ghostMarker.fire 'click'

              layer._ghostMarker.on 'click', (e) ->
                layer._ghostMarker.off 'click'
                layer.selected = false
                $(document).trigger E.Events.Map.new.cancel, uuid: layer._childLayer.feature.properties.uuid, parentId: layer.feature.properties.id
                layer._map.removeLayer layer._ghostMarker
                layer._map.removeLayer layer._childLayer
                delete layer._ghostIcon
                delete layer._childLayer
                insertionMarker()

              layer._ghostMarker.addTo layer._map

            insertionMarker = () ->
              className = 'ghost-icon insertion-ghost-icon'
              className += if layer.feature && layer.feature.properties && layer.feature.properties.intersected then ' warning' else ''
              layer._ghostIcon = new L.GhostIcon className: className, iconSize: [40, 40]
              layer._ghostMarker = L.marker(layer.getCenter(), icon: layer._ghostIcon)
              layer._ghostMarker.on 'click', (e) ->
                clone = _.cloneDeep(layer.toGeoJSON(17))
                clone.properties.style ||= {}
                clone.properties.style.color = '#44B51B'
                clone.properties.style.opacity = 0.35
                layer.selected = true
                clone.properties.registeredCropZoneId = clone.properties.id
                delete clone.properties.id
                delete clone.properties.uuid
                layer._map.fire L.Draw.Event.CREATED, layer: clone
                layer._ghostMarker.off 'click'
                layer._map.removeLayer layer._ghostMarker
                delete layer._ghostIcon
                deletionMarker()

              layer._ghostMarker.addTo layer._map
              layer.addTo layer._map

            layer.on 'add', (e) ->
              insertionMarker()

              unless E.map.backupSelectedIds.indexOf(layer.feature.properties.id) == -1
                layer._ghostMarker.fire 'click'

            layer.on 'remove', (e) ->
              if layer._ghostMarker
                layer._map.removeLayer layer._ghostMarker
                layer._ghostMarker.off 'click'
              if !!layer._childLayer
                layer._map.removeLayer layer._childLayer

          style = (feature) ->
            color = if feature.properties.intersected? then "#FF9D00" else "#1195F5"
            color: color, fillOpacity: 0, opacity: 1, dashArray: '6, 6', fill: false

          cropZonesSerie = [{crop_zones: data}, [name: 'crop_zones', label: "RPG", type: 'simple', index: true, serie: 'crop_zones', onEachFeature: onEachFeature, style: style]]

          @_cartography.addOverlay(cropZonesSerie)

        @asyncLoading(url, onSuccess)

    asyncLoading: (url, onSuccess) =>
      return unless url

      $.ajax
        method: 'GET'
        dataType: 'json'
        url: url
        beforeSend: =>
          @_cropZonesLoading = true
        success: (data) =>
          onSuccess.call @, data
          @_cropZonesLoading = false
        error: () =>
        complete: () =>

    # HACK: Remove this when the obj interface in events has been smoothed out
    normalizeRecord: (obj) ->
      obj.surface = obj.area unless obj.surface || !obj.area

      obj.registeredCropZoneId = obj.shape.properties.registeredCropZoneId if obj.shape && obj.shape.properties && obj.shape.properties.registeredCropZoneId
      obj.cityName = obj.shape.properties.cityName if obj.shape && obj.shape.properties && obj.shape.properties.cityName

      obj.shape = obj.shape.geometry if obj.shape && obj.shape.geometry
      obj

    isLocked: (plotShape, crops) =>
      productionStartedOn = new Date $("#edit-crop-form #crop_started_on").val()
      productionStoppedOn = new Date $("#edit-crop-form #crop_stopped_on").val()

      return [false, null, null] if crops.length < 1

      result = []

      relevantCrops = crops.filter (crop) ->
        cropStartedOn = new Date crop.startedOn
        cropStoppedOn = new Date crop.stoppedOn
        !(cropStartedOn > productionStoppedOn || cropStoppedOn < productionStartedOn)


      return [false, null, null] if relevantCrops.length < 1

      cropsUnion = @union.call @, relevantCrops.map((relevantCrop) -> relevantCrop.shape)
      cropsUnion.properties.crops = relevantCrops.map((relevantCrop) -> relevantCrop.uuid)

      difference = @difference plotShape, cropsUnion

      availableGeometries = [] unless difference
      availableGeometries ||= difference.geometry.coordinates.map (polygon) ->
        geojson = L.GeoJSON.asFeature(coordinates: polygon, type: 'Polygon')
        properties = if plotShape.properties.parent
          plotShape.properties.parent
        else
          plotShape.properties

        geojson.properties.parent = properties
        geojson.properties.name = plotShape.properties.name
        geojson

      lockedGeometries = cropsUnion.geometry.coordinates.map (polygon) =>
        c = polygon

        if cropsUnion.geometry.type is 'MultiPolygon'
          c = polygon[0]

        geojson = L.GeoJSON.asFeature(coordinates: [c], type: 'Polygon')

        matchingCrops = []
        for crop in relevantCrops
          matchingCrops.push crop if @contains geojson, crop.shape

        cropsStartedOn = Math.min.apply(Math, matchingCrops.map (matchingCrop) -> new Date matchingCrop.startedOn)
        cropsStoppedOn = Math.max.apply(Math, matchingCrops.map (matchingCrop) -> new Date matchingCrop.stoppedOn)

        cropNatures = matchingCrops.sort((a, b) ->
          E.util.sortBy('startedOn', a, b, false)
        ).map((sortedCrop) ->
          sortedCrop.productionNatureHumanName
        )

        uniqCropNatures = []
        for cropNature in cropNatures
          uniqCropNatures.push cropNature unless uniqCropNatures.includes cropNature

        uniqCropNatures = uniqCropNatures.join(', ')

        [label, options] = if (cropsStartedOn >= productionStartedOn && cropsStoppedOn <= productionStoppedOn) || (cropsStartedOn <= productionStartedOn && cropsStoppedOn >= productionStoppedOn)

          ["from_to_date_html", from: moment(cropsStartedOn).format('DD-MM-YYYY'), to: moment(cropsStoppedOn).format('DD-MM-YYYY')]

        else if cropsStartedOn < productionStartedOn && cropsStoppedOn >= productionStartedOn && cropsStoppedOn <= productionStoppedOn

          ["to_date_html", to: moment(cropsStoppedOn).format('DD-MM-YYYY')]

        else if cropsStoppedOn > productionStoppedOn && cropsStartedOn >= productionStartedOn && cropsStartedOn <= productionStoppedOn

          ["from_date_html", from: moment(cropsStartedOn).format('DD-MM-YYYY')]


        message = I18n.t "#{I18n.rootKey}.leaflet.locking.#{label}", Object.assign production: uniqCropNatures, options
        message =  I18n.t "#{I18n.rootKey}.leaflet.locking.label_html", content: message

        geojson.properties.label = message
        geojson

      [true, lockedGeometries, availableGeometries]

  $.loadMap = ->
    return unless $("*[data-cartography]").length
    $el = $("*[data-cartography]").first()
    mapAlreadyInitialized = $("*[data-cartography]").data('map-id') is null or $("*[data-cartography]").data('map-id')?
    return if mapAlreadyInitialized
    opts = $el.data("cartography")
    console.log(opts)

    opts.bounds = bounds if bounds = localStorage.getItem("bounds")
   
    E.map = new E.Map($el[0], opts)
  $(document).ready $.loadMap

  # $(document).on 'ekylibre:db:ready', ->
  #   $(document).ready $.loadMap
  # $(document).on "page:load cocoon:after-insert cell:load dialog:show", $.loadMap

  # $(document).on E.Events.Map.initializing, "*[data-cartography]", (e) =>
    
    # $(e.target).css('visibility', 'hidden')

  $(document).on E.Events.Map.ready, "*[data-cartography]", (e) =>
  
    $(e.target).css('visibility', 'visible')



) ekylibre, jQuery
