ekylibre.cviLandParcelsList ||= {}

((E, $) ->
  selectedCviLandParcels = []

  $(document).on 'ekylibre:map:events:initializing', ->
    addClickEventToIds()
    addColumn(0)

  $(document).on 'ready', ->
    formatRow()
    addClickEventToIds()
  
  $(document).on 'list:page:change', ->
    selectedCviLandParcels = []
    formatRow()
    addClickEventToIds()
    addColumn(0)
    
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

  addColumn = (position) ->
    $groupButton =  $('#group-cvi-land-parcels')
    $cutButton = $('#cut-cvi-land-parcel')

    $('#cvi_land_parcels-list').find('tr:not(.edit-form)').each (index, element) ->
      return $(element).find('th').eq(position).before('<th></td>') if index == 0
      id = parseInt($(element).attr('id').replace('r', ''))
      $(element).find('td').eq(position).before("<td><input type=\'checkbox\' value=\'#{id}\'></td>")
      $groupButton.hide()
      $cutButton.hide()
    


    $('#cvi_land_parcels-list').find('input[type=checkbox]').each ->
      $(this).change ->
        id = parseInt(this.value)
        layer = E.map.select id, false, 'cvi_land_parcels'
        if this.checked
          layer.setStyle( fillOpacity: 0.3)
          selectedCviLandParcels.push id
          goToPolygonCenter(id) if selectedCviLandParcels.length == 1
        else
          layer.setStyle( fillOpacity: 0)
          index = selectedCviLandParcels.indexOf(id) 
          selectedCviLandParcels.splice(index, 1)
        params = selectedCviLandParcels.map (id) ->
            "cvi_land_parcel_ids[]=#{id}"
          .join('&')
        $groupButton.attr(href: "/backend/cvi_land_parcels/group?#{params}")

        if selectedCviLandParcels.length == 1
          $groupButton.hide()
          $cutButton.show()
        else if selectedCviLandParcels.length == 0
          $groupButton.hide()
          $cutButton.hide()
        else
          $groupButton.show()
          $cutButton.hide()

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