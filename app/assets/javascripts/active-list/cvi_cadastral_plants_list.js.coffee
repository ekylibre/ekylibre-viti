((E, $) ->

  E.cvi_cadastral_plants_map_list = new E.Lister
  $(document).on 'ekylibre:map:events:ready list:page:change', ->
    goToPolygonCenterLinks('cvi_cadastral_plants_map','cvi_cadastral_plants',3)

  addClickEventToIds = () ->
    $('#cvi_cadastral_plants_map-list.active-list td.c3 a').each ->
      element = $(this)
      element.click (e) ->
        e.preventDefault()
        cvi_cadastral_plant_id = parseInt(element.closest('tr').attr('id').replace('r', ''))
        goToPolygonCenter(cvi_cadastral_plant_id)

  goToPolygonCenter = (id) ->
    E.map.centerLayer(id, true, "cvi_cadastral_plants")

  $(document).ready ->
    formatRow()
    manageErrorMessage()

  $(document).on 'list:page:change', ->
    formatRow()
    manageErrorMessage()
    # Used to rebind activelist items on page changing
    addClickEventToIds()

  formatRow = ->
    $('[id^=cvi_cadastral_plants] tr').each ->
      $tr = $(this)
      if $tr.attr('id')
        land_parcel_id = $tr.children( ".c0" ).text()

      if land_parcel_id == ""
        $tr.children().addClass('invalid-row')
      else
        if $tr.closest("[id^=cvi_cadastral_plants]").attr('id') == "cvi_cadastral_plants_map-list"
          $tr.children( ".c3" ).html("<a href='#' >#{$tr.children( ".c3" ).html()} </a>")

  manageErrorMessage = ->
    $('[id^=cvi_cadastral_plants] tr').each ->
      if $(this).attr('id')
        land_parcel_id = $(this).children( ".c0" ).text()

      if land_parcel_id == "" and $('#error').children().length == 0
        $('#error').append(errorMessage)

  errorMessage =
    "<div class='flash error' data-alert=''>
      <div class='icon'></div>
      <div class='message'>
        <h3>#{I18n.t( 'front-end.notifications.levels.error')}</h3>
        <p>#{I18n.t( 'front-end.notifications.messages.unvalid_cvi_cadastral_plant')}</p>
      </div>
    </div>"

) ekylibre, jQuery