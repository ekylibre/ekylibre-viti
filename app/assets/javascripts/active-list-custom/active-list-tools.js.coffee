((E, A, $) ->

  A.goToPolygonCenterLinks = (layerName, columnId, listName = layerName) ->
    $("##{listName}-list.active-list td.c#{columnId} a").each ->
      element = $(this)
      element.click (e) ->
        e.preventDefault()
        polygon_id = parseInt(element.closest('tr').attr('id').replace('r', ''))
        E.map.centerLayer(polygon_id, true, layerName)

) ekylibre, window.ActiveListTools = window.ActiveListTools || {}, jQuery