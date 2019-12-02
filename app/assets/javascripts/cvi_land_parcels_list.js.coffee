ekylibre.cviLandParcelsList ||= {}

((E, $) ->
  $(document).on 'ready ekylibre:map:events:ready list:page:change', ->
    formatRow()
    addClickEventToIds()
    addClickEventToIds()

  addClickEventToIds =  ->
    $('#cvi_land_parcels-list.active-list td.c2 a').each ->
      element = $(this)
      element.click (e) ->
        e.preventDefault()
        cvi_cadastral_plant_id = parseInt(element.closest('tr').attr('id').replace('r', ''))
        goToPolygonCenter(cvi_cadastral_plant_id)

  goToPolygonCenter = (id) ->
    E.map.centerLayer(id, true, "cvi_land_parcels")

  formatRow = ->
    $('[id^=cvi_land_parcels] tr').each ->
      $tr = $(this)
      if $tr.attr('id')
        land_parcel_id = $tr.children( ".c0" ).text()
      
      $tr.children( ".c2" ).html("<a href='#' >#{$tr.children( ".c2" ).html()} </a>")

  E.cviLandParcelsList.cancelForm = ->
    $('tr').not('.edit-form').not($('.edit-form').prev('tr')).toggleClass('disabled-row')
    id = parseInt($('tr.edit-form').prev('tr').attr('id').replace('r', ''))
    $('tr.edit-form').remove()
    E.map.edit(id, 'cvi_land_parcels', cancel: true)
    return false

  $(document).ready ->
    $(document).on E.Events.Map.edit.change, (e, obj) ->
      $("input[name='cvi_land_parcel[shape]']").val(JSON.stringify(obj.shape.geometry))
      $("input[name='cvi_land_parcel[area]']").val(formatArea(obj.area / 10000))

  formatArea = (area) ->
    ha_area = Math.trunc(area)
    a_area = Math.trunc((area - ha_area) * 100)
    ca_area = Math.trunc((area - ha_area - a_area / 100) * 10000)
    result = "#{ha_area} ha #{a_area} a #{ca_area} ca"

) ekylibre, jQuery