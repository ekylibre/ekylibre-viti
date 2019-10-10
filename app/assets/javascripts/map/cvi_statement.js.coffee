((E, $) ->
    $(document).on 'ekylibre:map:events:ready', ->
      unless $('#cvi_cadastral_plants-list').length > 0
        return
      
      $(document).on 'list:page:change', ->
        handleClick()

      handleClick()

    handleClick =  ->
      $('#cvi_cadastral_plants-list.active-list td.c3 a').each ->
        element = $(this)
        element.click (e) ->
          e.preventDefault()
          cvi_cadastral_plant_id = element.closest('tr').find('.c0').text()
          E.map.centerLayer(parseInt(cvi_cadastral_plant_id), true, "cvi_cadastral_plants")

) ekylibre, jQuery