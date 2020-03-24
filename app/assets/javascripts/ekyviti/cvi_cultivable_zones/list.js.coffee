ekylibre.cviCultivableZones ||= {}

((E, $) ->
  E.cviCultivableZones.list = {
    selectedCviCultivableZones: [],

    init: ->
      this.formatRow()
      E.list.bindCellsClickToCenterLayer('cvi_cultivable_zones', 2)
      this.selectedCviCultivableZones = []
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
      $(document).on "click", "#cvi_cultivable_zones-list td>input[data-list-selector]", (event) ->
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
      
      $(document).on "change", "#cvi_cultivable_zones-list [data-list-selector=all]", (event) ->
        list = E.cviCultivableZones.list
        $list = $(this.closest('*[data-list-source]'))
        if this.checked
          E.cviCultivableZones.list.selectedCviCultivableZones = Object.keys($list.prop('selection'))
          for id in E.cviCultivableZones.list.selectedCviCultivableZones
            layer = E.map.select parseInt(id) , false, 'cvi_cultivable_zones'
            layer.setStyle(color: "#6f9bee")
        else
          E.cviCultivableZones.list.selectedCviCultivableZones = []
          E.map._cartography.getOverlay('cvi_cultivable_zones').setStyle(color: "#C5D4F0")
          E.map.setView()
        list.manageButtons()

    addButton: ->
      $(E.templates.cviCultivableZonesButton()).insertBefore('#cvi_cultivable_zones-list tr:first')

    formatRow: ->
      $('[id^=cvi_cultivable_zones] tr th:nth-child(9) > i').remove().html(I18n.t("front-end.active_list.labels.manage_land_parcels"))
      $('[id^=cvi_cultivable_zones] tr th:nth-child(10) > i').remove()
      $('[id^=cvi_cultivable_zones] tr th:nth-child(11) > i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c8 i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c8 a').addClass('btn btn-primary')
      $('[id^=cvi_cultivable_zones] tr td.c9 i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c9 a').addClass('btn btn-primary')
      $('[id^=cvi_cultivable_zones] tr td.c10 i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c10 a').addClass('btn btn-primary')
      $('[id^=cvi_cultivable_zones] tr.completed').find('td.c9 a').html(I18n.t("front-end.active_list.labels.edit"))
  }

) ekylibre, jQuery