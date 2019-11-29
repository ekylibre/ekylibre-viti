((E, $) ->
  $(document).on 'ready ekylibre:map:events:ready list:page:change', ->
    formatRow()
    addClickEventToIds()
    addClickEventToIds()

  addClickEventToIds =  ->
    $('#cvi_land_parcels-list.active-list td.c2 a').each ->
      element = $(this)
      element.click (e) ->
        e.preventDefault()
        cvi_cadastral_plant_id = parseInt(element.closest('tr').attr('id').replace('r', ''))
        goToPolygonCenter(cvi_cadastral_plant_id)

  goToPolygonCenter = (id) ->
    E.map.centerLayer(id, true, "cvi_land_parcels")

  formatRow = ->
    $('[id^=cvi_land_parcels] tr').each ->
      $tr = $(this)
      if $tr.attr('id')
        land_parcel_id = $tr.children( ".c0" ).text()
      
      $tr.children( ".c2" ).html("<a href='#' >#{$tr.children( ".c2" ).html()} </a>")

) ekylibre, jQuery