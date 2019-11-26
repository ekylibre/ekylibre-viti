((E, $) ->
  $(document).on 'ready ekylibre:map:events:ready list:page:change', ->
    return unless $('[id^=cvi_cadastral_plants].active-list').length > 0
    formatRow()
    manageErrorMessage()
    ActiveListTools.goToPolygonCenterLinks('cvi_cadastral_plants',3,'cvi_cadastral_plants_map')


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