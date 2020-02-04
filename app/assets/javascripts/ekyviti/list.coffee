ekylibre.list ||= {}

((E, $) ->
  E.list = {
    bindCellsClickToCenterLayer: (layerName, columnId, listName = layerName) ->
      $rows = $("[id^=#{listName}] tr")
      cellSelector = "td.c#{columnId}"
      
      $rows.each ->
        $cell = $(this).find(cellSelector)
        cellValue = $cell.html()
        $cell.html("<a href='#'>#{cellValue}</a>")
        
      $rows.find(cellSelector).find('a').each ->
        element = $(this)
        element.click (e) ->
          e.preventDefault()
          polygon_id = parseInt(element.closest('tr').attr('id').replace('r', ''))
          E.map.centerLayer(polygon_id, true, layerName)

    render: ->
      $("*[data-list-change-page-size].check").click()

    disable: ->
      $form = $('.edit-form')
      $editedRow =  $('.edit-form').prev('tr')
      $rowsToDisable = $('tbody').find('tr')
      $rowActionLinks = $('tr').find('a.edit, a.delete')

      for $element in [$rowsToDisable, $form, $editedRow]
        $element.toggleClass("disabled-row")
      $rowActionLinks.toggleClass("disabled-link")

    addForm: (form, id) ->
      $row = $("#r#{id}")
      $form =  $row.next("tr.edit-form")
      if $form.length == 0
        $row.after(form)
      else
        $form.replaceWith(form)
    
    addCheckboxes: (listName) ->
      $("##{listName}-list").find('tr:not(.edit-form)').each (index, element) ->
        return $(element).find('th').eq(0).before('<th></td>') if index == 0
        id = parseInt($(element).attr('id').replace('r', ''))
        $(element).find('td').eq(0).before("<td><input type=\'checkbox\' value=\'#{id}\' data-list-selector=\'#{id}\'></td>")

  }

)(ekylibre, jQuery)