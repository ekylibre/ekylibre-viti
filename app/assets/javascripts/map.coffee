((E, $) ->
  E.Events ||= {}
  E.Events.Map = {}
  E.Events.Map.initializing = "ekylibre:map:events:initializing"
  E.Events.Map.ready = "ekylibre:map:events:ready"
  E.Events.Map.edit = {}
  E.Events.Map.edit.start = "cartography:events:edit:start"
  E.Events.Map.edit.complete = "cartography:events:edit:complete"
  E.Events.Map.edit.cancel = "cartography:events:edit:cancel"
  E.Events.Map.edit.change = "ekylibre:map:events:edit:change"
  E.Events.Map.split = {}
  E.Events.Map.split.change = "ekylibre:map:events:split:change"

  class E.Map
    constructor: (@el, options = {})  ->
      $(@el).trigger E.Events.Map.initializing
      @_cartography = new Cartography.Map @el, options
      @initHooks()
      @asyncLayersLoading()

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

) ekylibre, jQuery
