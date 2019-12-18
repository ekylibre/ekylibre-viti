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
    manageErrorMessage()

  $(document).on 'list:page:change', ->
    manageErrorMessage()
    # Used to rebind activelist items on page changing
    addClickEventToIds()

  manageErrorMessage = ->
    if $("tr.invalid").length > 0 and $('#error').children().length == 0
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