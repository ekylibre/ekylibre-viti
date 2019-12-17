((E, $) ->

  $(document).on 'ekylibre:map:events:ready list:page:change', ->
    if $('[id^=cvi_cultivable_zones].active-list').length > 0
      formatRow()
      ActiveListTools.goToPolygonCenterLinks('cvi_cultivable_zones', 3)

  formatRow = ->
    $('[id^=cvi_cultivable_zones] tr th:nth-child(10) > i').remove()
    $('[id^=cvi_cultivable_zones] tr th:nth-child(11) > i').remove()
    $('[id^=cvi_cultivable_zones] tr').each ->
      $tr = $(this)
      if $tr.attr('id')
        land_parcel_id = $tr.children( ".c0" ).text()
      
      $tr.children( ".c3" ).html("<a href='#' >#{$tr.children( ".c3" ).html()} </a>")

      status  = $tr.children( ".c8" ).html()

      if status == I18n.t("front-end.enumerize.cvi_cultivable_zone.land_parcels_status.not_created")
        $tr.children( ".c8" ).addClass('land-parcels-not-created')
      else
        $tr.children( ".c8" ).addClass('land-parcels-created')
      
      $tr.children( ".c9" ).find('i').remove()
      $tr.children( ".c9" ).children().addClass('btn btn-primary')

      $tr.children( ".c10" ).find('i').remove()
      $tr.children( ".c10" ).children().addClass('btn btn-primary')

) ekylibre, jQuery