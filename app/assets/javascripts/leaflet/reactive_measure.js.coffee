# Extends featureGroup to return measure. Works with inherited classes (Leaflet.MultiPolygon, Leaflet.MultiPolyline)
Leaflet.FeatureGroup.include
  getMeasure: () ->

    measure =
      perimeter: 0
      area: 0

    this.eachLayer (layer) ->
      m = layer.getMeasure()
      measure.perimeter += m.perimeter
      measure.area += m.area

    measure


Leaflet.Polygon.include
  ###
  # Get centroid of the polygon in square meters
  # Portage from leaflet1.0.0-rc1: https://github.com/Leaflet/Leaflet/blob/master/src/layer/vector/Polygon.js
  # @return {number} polygon centroid
   ###
  __getCenter: ->
    @__project()
    points = @_rings[0]
    len = points.length
    if !len
      return null
    # polygon centroid algorithm; only uses the first ring if there are multiple
    area = x = y = 0
    i = 0
    j = len - 1
    while i < len
      p1 = points[i]
      p2 = points[j]
      f = p1.y * p2.x - (p2.y * p1.x)
      x += (p1.x + p2.x) * f
      y += (p1.y + p2.y) * f
      area += f * 3
      j = i++
    if area == 0
      # Polygon is so small that all points are on same pixel.
      center = points[0]
    else
      center = [
        x / area
        y / area
      ]
    @_map.layerPointToLatLng center

Leaflet.Polyline.include
  ###
  # Return LatLngs as array of [lat, lng] pair.
  # @return {Array} [[lat,lng], [lat,lng]]
   ###
  getLatLngsAsArray: ->
    arr = []
    for latlng in @_latlngs
      arr.push [latlng.lat, latlng.lng]
    arr

  ###
  # Get center of the polyline in meters
  # Portage from leaflet1.0.0-rc1: https://github.com/Leaflet/Leaflet/blob/master/src/layer/vector/Polyline.js
  # @return {number} polyline center
   ###
  __getCenter: ->
    @__project()
    i = undefined
    halfDist = undefined
    segDist = undefined
    dist = undefined
    p1 = undefined
    p2 = undefined
    ratio = undefined
    points = @_rings[0]
    len = points.length
    if !len
      return null
    # polyline centroid algorithm; only uses the first ring if there are multiple
    i = 0
    halfDist = 0
    while i < len - 1
      halfDist += points[i].distanceTo(points[i + 1]) / 2
      i++
    # The line is so small in the current view that all points are on the same pixel.
    if halfDist == 0
      return @_map.layerPointToLatLng(points[0])
    i = 0
    dist = 0
    while i < len - 1
      p1 = points[i]
      p2 = points[i + 1]
      segDist = p1.distanceTo(p2)
      dist += segDist
      if dist > halfDist
        ratio = (dist - halfDist) / segDist
        return @_map.layerPointToLatLng([
          p2.x - (ratio * (p2.x - (p1.x)))
          p2.y - (ratio * (p2.y - (p1.y)))
        ])
      i++
    return

  __project: ->
    pxBounds = new (Leaflet.Bounds)
    @_rings = []
    @__projectLatlngs @_latlngs, @_rings, pxBounds
    return

  # recursively turns latlngs into a set of rings with projected coordinates
  __projectLatlngs: (latlngs, result, projectedBounds) ->
    flat = latlngs[0] instanceof Leaflet.LatLng
    len = latlngs.length
    i = undefined
    ring = undefined
    if flat
      ring = []
      i = 0
      while i < len
        ring[i] = @_map.latLngToLayerPoint(latlngs[i])
        projectedBounds.extend ring[i]
        i++
      result.push ring
    else
      i = 0
      while i < len
        @__projectLatlngs latlngs[i], result, projectedBounds
        i++
    return

  getMeasure: () ->
    g = new Leaflet.GeographicUtil.Polygon @getLatLngsAsArray()

    measure =
      perimeter: g.perimeter()
      area: g.area()

    measure


Leaflet.Draw.Polyline.include
  __addHooks: Leaflet.Draw.Polyline.prototype.addHooks
  __removeHooks: Leaflet.Draw.Polyline.prototype.removeHooks
  __vertexChanged: Leaflet.Draw.Polyline.prototype._vertexChanged

  _vertexChanged: () ->
    @__vertexChanged.apply this, arguments
    @_tooltip.hide()


  __onMouseMove: (e) ->
    @_tooltip.hide() if @_tooltip?
    return unless @_markers.length > 0
    newPos = @_map.mouseEventToLayerPoint(e.originalEvent)
    mouseLatLng = @_map.layerPointToLatLng(newPos)

    latLngArray = []
    for latLng in @_poly.getLatLngs()
      latLngArray.push latLng
    latLngArray.push mouseLatLng

    # draw a polyline
    if @_markers.length == 1
      clone = Leaflet.polyline latLngArray

    # draw a polygon
    if @_markers.length >= 2
      clone = Leaflet.polygon latLngArray

    clone._map = @_map
    center = clone.__getCenter()

    g = new Leaflet.GeographicUtil.Polygon clone.getLatLngsAsArray()

    measure =
      perimeter: g.perimeter()
      area: g.area()

    e.target.reactiveMeasureControl.updateContent measure, {selection: true}



  addHooks: () ->
    @__addHooks.apply this, arguments
    @_map.on 'mousemove', @__onMouseMove, this
    return

  removeHooks: () ->
    if @_map.reactiveMeasureControl
      @_map.off 'mousemove'
    @__removeHooks.apply this, arguments
    return

Leaflet.Edit.Poly.include
  __addHooks: Leaflet.Edit.Poly.prototype.addHooks
  __removeHooks: Leaflet.Edit.Poly.prototype.removeHooks

  __onHandlerDrag: (e) ->
    center = @_poly.__getCenter()

    g = new Leaflet.GeographicUtil.Polygon @_poly.getLatLngsAsArray()

    measure =
      perimeter: g.perimeter()
      area: g.area()

    Leaflet.extend(Leaflet.Draw.Polyline.prototype.options, target: e.marker.getLatLng())

    @_poly._map.reactiveMeasureControl.updateContent(measure, {selection: true}) if @_poly._map?


  addHooks: () ->
    @__addHooks.apply this, arguments
    this._poly.on 'editdrag', @__onHandlerDrag, this

  removeHooks: () ->

    g = new Leaflet.GeographicUtil.Polygon @_poly.getLatLngsAsArray()

    measure =
      perimeter: g.perimeter()
      area: g.area()

    @._poly._map.reactiveMeasureControl.updateContent measure, {selection: false} if @._poly._map?

    if Leaflet.EditToolbar.reactiveMeasure
      this._poly.off 'editdrag'

    @__removeHooks.apply this, arguments

Leaflet.Edit.PolyVerticesEdit.include
  __onTouchMove: Leaflet.Edit.PolyVerticesEdit::_onTouchMove
  __removeMarker: Leaflet.Edit.PolyVerticesEdit::_removeMarker

  _onMarkerDrag: (e) ->
    marker = e.target
    Leaflet.extend marker._origLatLng, marker._latlng
    if marker._middleLeft
      marker._middleLeft.setLatLng @_getMiddleLatLng(marker._prev, marker)
    if marker._middleRight
      marker._middleRight.setLatLng @_getMiddleLatLng(marker, marker._next)
    @_poly.redraw()
    # Overrides to track mouse position
    @_poly.fire 'editdrag', marker: e.target
    return

  _onTouchMove: (e) ->
    @__onTouchMove.apply @, arguments
    @_poly.fire 'editdrag'

  _removeMarker: (marker) ->
    @__removeMarker.apply @, arguments
    @_poly.fire 'editdrag', marker: marker


Leaflet.LatLng.prototype.toArray = ->
  [@lat, @lng]

Leaflet.Tooltip.include
  __initialize: Leaflet.Tooltip.prototype.initialize
  __dispose: Leaflet.Tooltip.prototype.dispose

  initialize: (map,options = {}) ->
    @__initialize.apply this, arguments

  dispose: ->
    @_map.off 'mouseover'
    @__dispose.apply this, arguments

  __updateTooltipMeasure: (latLng, measure = {}, options = {}) ->
    labelText =
      text: ''
    #TODO: use Leaflet.drawLocal to i18n tooltip
    if measure['perimeter']
      labelText['text'] += "<span class='leaflet-draw-tooltip-measure perimeter'>#{Leaflet.GeometryUtil.readableDistance(measure.perimeter, !!options.metric, !!options.feet)}</span>"

    if measure['area']
      labelText['text']  += "<span class='leaflet-draw-tooltip-measure area'>#{Leaflet.GeometryUtil.readableArea(measure.area, !!options.metric)}</span>"

    if latLng
      @updateContent labelText
      @__updatePosition latLng, options

    return

  __updatePosition: (latlng, options = {}) ->
    pos = @_map.latLngToLayerPoint(latlng)
    labelWidth = @_container.offsetWidth

    map_width =  @_map.getContainer().offsetWidth
    Leaflet.DomUtil.removeClass(@_container, 'leaflet-draw-tooltip-left')

    if @_container
      @_container.style.visibility = 'inherit'
      container = @_map.layerPointToContainerPoint pos
      styles = window.getComputedStyle(@_container)

      container_width = @_container.offsetWidth + parseInt(styles.paddingLeft) + parseInt(styles.paddingRight) + parseInt(styles.marginLeft) + parseInt(styles.marginRight)


      if (container.x < 0 || container.x > (map_width - container_width) || container.y < @_container.offsetHeight)
        pos = pos.add(Leaflet.point(-container_width, 0))
        Leaflet.DomUtil.addClass(@_container, 'leaflet-draw-tooltip-left')

      Leaflet.DomUtil.setPosition(@_container, pos)

  hide: ->
    @_container.style.visibility = 'hidden'

Leaflet.EditToolbar.Edit.include
  _onMouseMove: (e) ->
    return

Leaflet.EditToolbar.Delete.include
  _onMouseMove: (e) ->
    return

###
#Add Configuration options
###

Leaflet.DrawToolbar.include
  __initialize: Leaflet.DrawToolbar.prototype.initialize

  initialize: (options) ->
    @__initialize.apply this, arguments
    return

Leaflet.EditToolbar.include
  __initialize: Leaflet.EditToolbar.prototype.initialize

  initialize: () ->
    @__initialize.apply this, arguments
    return


###
# Leaflet.Draw Patches
 ###
Leaflet.EditToolbar.Edit.include
  __removeHooks: Leaflet.EditToolbar.Edit::removeHooks
  __revertLayer: Leaflet.EditToolbar.Edit::_revertLayer

  # Patch missing event
  removeHooks: ->
    @__removeHooks.apply @, arguments
    if @_map
      @_map.off 'draw:editvertex', @_updateTooltip, @

  # Patch handlers not reverted on cancel edit. See https://github.com/Leaflet/Leaflet.draw/issues/532
  _revertLayer: (layer) ->
    id = Leaflet.Util.stamp layer
    @__revertLayer.apply @, arguments
    layer.editing.latlngs = this._uneditedLayerProps[id].latlngs
    layer.editing._poly._latlngs = this._uneditedLayerProps[id].latlngs
    layer.editing._verticesHandlers[0]._latlngs = this._uneditedLayerProps[id].latlngs

  _editStyle: ->
    # missing method declaration in Leaflet.Draw
    return

Leaflet.EditToolbar.include
  # Patch _activeMode is null
  _save: ->
    handler = this._activeMode.handler
    handler.save()
    handler.disable()

Leaflet.ReactiveMeasureControl = Leaflet.Control.extend
  options:
    position: 'bottomright'
    metric: true
    feet: false
    measure:
      perimeter: 0
      area: 0

  initialize: (layers, options = {}) ->
    Leaflet.Util.setOptions @, options
    # Be sure to reset
    @options.measure.perimeter = 0
    @options.measure.area = 0

    if layers.getLayers().length > 0
      layers.eachLayer (layer) =>
        if typeof layer.getMeasure is 'function'
          m = layer.getMeasure()
          @options.measure.perimeter += m.perimeter
          @options.measure.area += m.area

  onAdd: (map) ->
    @_container = Leaflet.DomUtil.create('div', "reactive-measure-control #{map._leaflet_id}")
    map.reactiveMeasureControl = @

    if map and @_container
      @updateContent(@options.measure)
    @_container

  updateContent: (measure = {}, options = {}) ->
    text = ''
    if measure['perimeter']
      text += "<span class='leaflet-draw-tooltip-measure perimeter'>#{Leaflet.GeometryUtil.readableDistance(measure.perimeter, !!@options.metric, !!options.feet)}</span>"
    if measure['area']
      text += "<span class='leaflet-draw-tooltip-measure area'>#{Leaflet.GeometryUtil.readableArea(measure.area, !!@options.metric)}</span>"

    if options.selection? && options.selection is true
      Leaflet.DomUtil.addClass @_container, 'selection'
    else
      Leaflet.DomUtil.removeClass @_container, 'selection'

    @_container.innerHTML = text

    return