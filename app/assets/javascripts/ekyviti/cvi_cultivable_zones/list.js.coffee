ekylibre.cviCultivableZones ||= {}

((E, $) ->
  E.cviCultivableZones.list = {
    init: ->
      this.formatRow()
      E.list.bindCellsClickToCenterLayer('cvi_cultivable_zones', 2)

    formatRow: ->
      $('[id^=cvi_cultivable_zones] tr th:nth-child(9) > i').remove()
      $('[id^=cvi_cultivable_zones] tr th:nth-child(10) > i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c8 i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c8 a').addClass('btn btn-primary')
      $('[id^=cvi_cultivable_zones] tr td.c9 i').remove()
      $('[id^=cvi_cultivable_zones] tr td.c9 a').addClass('btn btn-primary')
  }

  $(document).ready ->
    if $('[id^=cvi_cultivable_zones].active-list').length > 0
      E.cviCultivableZones.list.init()
  
  $(document).on 'list:page:change', ->
    if  $('[id^=cvi_cultivable_zones].active-list').length > 0
      E.cviCultivableZones.list.init()

) ekylibre, jQuery