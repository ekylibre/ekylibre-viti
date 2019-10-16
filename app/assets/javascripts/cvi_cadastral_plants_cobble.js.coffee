((E, $) ->
  $(document).on 'ekylibre:map:events:ready list:page:change', ->
    addClickEventToIds()

  addClickEventToIds =  ->
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
    hideLandParcelIdColumn()
    hideLandParcelIdSetting()

  $(document).on 'list:page:change', ->
    formatRow()
    manageErrorMessage()
    hideLandParcelIdColumn()
    hideLandParcelIdSetting()

  formatRow = ->
    $('[id^=cvi_cadastral_plants] tr').each ->
      if $(this).attr('id')
        land_parcel_id = $(this).children( ".c0" ).text()

      if land_parcel_id == ""
        $(this).children().css( 'cssText', 'color: red !important' )
      else
        $(this).children( ".c2" ).children().remove()
        $(this).children( ".c1" ).children().remove()

  manageErrorMessage = ->
    $('[id^=cvi_cadastral_plants] tr').each ->
      if $(this).attr('id')
        land_parcel_id = $(this).children( ".c0" ).text()

      if land_parcel_id == "" and $('#error').children().length == 0
        $('#error').append(errorMessage)

  hideLandParcelIdColumn = ->
    $('[id^=cvi_cadastral_plants] .c0').hide()
    $('[id^=cvi_cadastral_plants] tr > th:first-child').hide()

  hideLandParcelIdSetting = ->

    $("[id^=cvi-cadastral-plants] span.list-settings li:nth-child(2) ul li:first-child").hide()


  errorMessage =
    "<div class='flash error' data-alert=''>
      <div class='icon'></div>
      <div class='message'>
        <h3>#{I18n.t( 'front-end.notifications.levels.error')}</h3>
        <p>#{I18n.t( 'front-end.notifications.messages.unvalid_cvi_cadastral_plant')}</p>
      </div>
    </div>"

) ekylibre, jQuery