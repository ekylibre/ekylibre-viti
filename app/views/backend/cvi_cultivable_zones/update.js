ekylibre.list.render()

map = ekylibre.map._cartography.map
currentBounds = map.getBounds()
map.remove()
$("#face-map > div.map-fullwidth.map-halfheight > div").remove()
$.loadMap()
ekylibre.map._cartography.map.fitBounds(currentBounds)