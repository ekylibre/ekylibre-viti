ekylibre.list ||= {}

((E, $) ->
  E.list = {
    bindCellsClickToCenterLayer: (layerName, columnId, listName = layerName) ->
      $("[id^=#{listName}] tr").each ->
        $(this).children( ".c#{columnId}" ).html("<a href='#' >#{$(this).children( ".c#{columnId}" ).html()} </a>")
      $("##{listName}-list.active-list td.c#{columnId} a").each ->
        element = $(this)
        element.click (e) ->
          e.preventDefault()
          polygon_id = parseInt(element.closest('tr').attr('id').replace('r', ''))
          E.map.centerLayer(polygon_id, true, layerName)

    render: ->
      $("*[data-list-change-page-size].check").click()

    disable: ->
      $('tr').not('.edit-form').not($('.edit-form').prev('tr')).toggleClass("disabled-row")
      $('.edit-form').prev('tr').find('a').toggleClass("disabled-link")

    addForm: (form, id) ->
      $row = $("#r#{id}")
      $form =  $row.next("tr.edit-form")
      if $form.length == 0
        $row.after(form)
      else
        $form.replaceWith(form)
  }

)(ekylibre, jQuery)