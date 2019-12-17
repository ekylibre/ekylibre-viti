ekylibre.cviLandParcelsList ||= {}

((E, $) ->
  selectedCviLandParcels = []
  splitFromCount = 0  

  $(document).ready ->
    formatRow()
    addClickEventToIds()
    addColumn(0)
  
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

  E.cviLandParcelsList.cancelEditForm = ->
    $('tr').not('.edit-form').not($('.edit-form').prev('tr')).toggleClass('disabled-row')
    id = parseInt($('tr.edit-form').prev('tr').attr('id').replace('r', ''))
    $('tr.edit-form').remove()
    E.map.edit(id, 'cvi_land_parcels', cancel: true)
    return false
  
  E.cviLandParcelsList.cancelsplitForm = ->
    $('.btn-container a').attr("disabled", false);
    $('input[type=checkbox]').attr('disabled', false)
    $('tr').not('.edit-form').not($('.edit-form').prev('tr')).toggleClass('disabled-row')
    id = parseInt($('tr.edit-form').prev('tr').attr('id').replace('r', ''))
    $('tr.edit-form').remove()
    map = E.map._cartography.map
    currentBounds = map.getBounds()
    map.remove()
    $("#face-map > div.map-fullwidth.map-halfheight > div").remove()
    $.loadMap()
    E.map._cartography.map.fitBounds(currentBounds)
    selectedCviLandParcels = []
    $("*[data-list-change-page-size].check").click()
    $('input[type=checkbox]').prop( "checked", false )*
    splitFromCount = 0  
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
        
        if selectedCviLandParcels.length == 1
          params = selectedCviLandParcels[0]
          $cutButton.attr(href: "/backend/cvi_land_parcels/#{params}/pre_split")
        else
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
    $(document).on E.Events.Map.split.change, (e, obj) ->
      vine_variety_id = $('#cvi_land_parcel_vine_variety_id').attr('value')
      old = obj.old
      old.vineVarietyId = vine_variety_id
      $form = $("#edit_cvi_land_parcel_#{old.uuid} div.fieldset-fields")
      if $('.edit-form .instructions').length == 1
        $('.edit-form .instructions').hide()
      
      if splitFromCount != obj.new.length
        $form.find(".split-form").remove()
        splitFromCount = obj.new.length
        for element in obj.new
          $form.append(splitLandParcelForm(old , element))
        $("input[data-selector]").each ->
          $(this).selector()
      else
        for element in obj.new
          index = element.num
          $("#new_cvi_land_parcels_#{index}_area").val(formatArea(element.area / 10000))
          $("#new_cvi_land_parcels_#{index}_shape").val(JSON.stringify(element.shape.geometry))

    $(document).on E.Events.Map.edit.change, (e, obj) ->
      $("input[name='cvi_land_parcel[shape]']").val(JSON.stringify(obj.shape.geometry))
      $("input[name='cvi_land_parcel[area]']").val(formatArea(obj.area / 10000))

  formatArea = (area) ->
    ha_area = Math.trunc(area)
    a_area = Math.trunc((area - ha_area) * 100)
    ca_area = Math.trunc((area - ha_area - a_area / 100) * 10000)
    result = "#{ha_area} ha #{a_area} a #{ca_area} ca"

  splitLandParcelForm = (oldObj, newObj) ->
    name = "#{oldObj.name}-#{newObj.num}"
    area = formatArea(newObj.area / 10000)
    index = newObj.num
    "<div class='split-form'>
      <div> Land parcel #{index} </div>
      <div class='control-group string required'>
        <label class='string required control-label' for='new_cvi_land_parcels_#{index}_name'><abbr title='Obligatoire'>*</abbr>
          Nom
        </label>
        <div class='controls'>
          <input class='string required' type='text' value='#{name}' name='new_cvi_land_parcels[#{index}][name]' id='new_cvi_land_parcels_#{index}_name'>
        </div>
      </div>
      <div class='control-group string optional'>
        <label class='string optional control-label' for='new_cvi_land_parcels_vine_variety_#{index}_id'>Cépage</label>
        <div class='controls'>
          <input data-selector='/backend/vine_varieties/unroll' data-selector-id='new_cvi_land_parcels_vine_variety_#{index}_id' class='string optional' type='text' value='#{oldObj.vineVarietyId}' name='new_cvi_land_parcels[#{index}][vine_variety_id]' id='new_cvi_land_parcels_vine_variety_#{index}_id'>
        </div>
      </div>
      <div class='control-group string optional disabled'>
        <label class='string optional disabled control-label' for='new_cvi_land_parcels_#{index}_area'>Superficie calculée</label>
        <div class='controls'>
          <input value='#{area}' class='string optional disabled' disabled='disabled' type='text' name='new_cvi_land_parcels[#{index}][area]' id='new_cvi_land_parcels_#{index}_area'>
        </div>
      </div>
      <input type='hidden' value=#{JSON.stringify(newObj.shape.geometry)} name='new_cvi_land_parcels[#{index}][shape]' id='new_cvi_land_parcels_#{index}_shape'>
    </div>"

) ekylibre, jQuery