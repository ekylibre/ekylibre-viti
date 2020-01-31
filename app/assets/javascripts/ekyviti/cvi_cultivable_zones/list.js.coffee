ekylibre.cviCultivableZones ||= {}

((E, $) ->
  E.cviCultivableZones.list = {
    selectedCviCultivableZones: [],

    init: ->
      this.formatRow()
      E.list.bindCellsClickToCenterLayer('cvi_cultivable_zones', 2)
      this.selectedCviCultivableZones = []
      this.addCheckboxes()
      this.addButton()
      this.bindCheckBoxes()

    manageButtons: ->
      $groupButton =  $('#group-cvi-land-parcels')
      $editButtons = $('td > a.edit')
      selectedCviCultivableZones = this.selectedCviCultivableZones
      if selectedCviCultivableZones.length == 0 || selectedCviCultivableZones.length == 1
        $groupButton.attr("disabled", true)
        $editButtons.removeClass("disabled-link")
      else
        $editButtons.addClass("disabled-link")
        $groupButton.removeAttr('disabled')
        params = selectedCviCultivableZones.map (id) ->
          "cvi_cultivable_zone_ids[]=#{id}"
        .join('&')
        $groupButton.attr(href: "/backend/cvi_cultivable_zones/group?#{params}")
    
    bindCheckBoxes: ->
      $(document).on "click", "*[data-list-source] td>input[data-list-selector]", (event) ->
        list = E.cviCultivableZones.list
        $list = $(this.closest('*[data-list-source]'))
        E.cviCultivableZones.list.selectedCviCultivableZones = Object.keys($list.prop('selection'))

        list.manageButtons()
        id = parseInt(this.value)
        layer = E.map.select id , false, 'cvi_cultivable_zones'
        unless this.checked 
          layer.setStyle(color: "#C5D4F0")
          if list.selectedCviCultivableZones.length == 0
            E.map.setView()
          return

        layer.setStyle(color: "#6f9bee")
        if list.selectedCviCultivableZones.length == 1
          E.map.centerLayer(id, true, "cvi_cultivable_zones") if list.selectedCviCultivableZones.length == 1

    addButton: ->
      $(E.templates.cviCultivableZonesButton()).insertBefore('#cvi_cultivable_zones-list tr:first')

    addCheckboxes: ->
      $('#cvi_cultivable_zones-list').find('tr:not(.edit-form)').each (index, element) ->
        return $(element).find('th').eq(0).before('<th></td>') if index == 0
        id = parseInt($(element).attr('id').replace('r', ''))
        $(element).find('td').eq(0).before("<td><input type=\'checkbox\' value=\'#{id}\' data-list-selector=\'#{id}\'></td>")


    formatRow: ->
      $('[id^=cvi_cultivable_zones] tr th:nth-child(9) > i').remove()
      $('[id^=cvi_cultivable_zones] tr th:nth-child(10) > i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c8 i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c8 a').addClass('btn btn-primary')
      $('[id^=cvi_cultivable_zones] tr td.c9 i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c9 a').addClass('btn btn-primary')
  }

) ekylibre, jQuery