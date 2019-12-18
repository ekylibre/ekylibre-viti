((E, $) ->
  E.cviLandParcels.list = {
    selectedCviLandParcels: [],

    init: ->
      E.list.bindCellsClickToCenterLayer('cvi_land_parcels', 2)
      this.addCheckboxes()
      this.bindCheckboxes()
      $('#group-cvi-land-parcels').hide()
      $('#cut-cvi-land-parcel').hide()
      this.selectedCviLandParcels = []
      
    render: ->
      E.list.render()
      $('.btn-container a').attr("disabled", false)

    disable: ->
      $('.btn-container a').attr("disabled", true)
      $('input[type=checkbox]').attr('disabled', true)
      E.list.disable()

    bindCheckboxes: ->
      selectedCviLandParcels = this.selectedCviLandParcels
      $groupButton =  $('#group-cvi-land-parcels')
      $cutButton = $('#cut-cvi-land-parcel')
      $('#cvi_land_parcels-list').find('input[type=checkbox]').each ->
        $(this).change ->
          id = parseInt(this.value)
          layer = E.map.select id, false, 'cvi_land_parcels'
          if this.checked
            layer.setStyle( fillOpacity: 0.3)
            selectedCviLandParcels.push id
            E.map.centerLayer(id, true, "cvi_land_parcels") if selectedCviLandParcels.length == 1
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
  
    addCheckboxes: ->
      $('#cvi_land_parcels-list').find('tr:not(.edit-form)').each (index, element) ->
        return $(element).find('th').eq(0).before('<th></td>') if index == 0
        id = parseInt($(element).attr('id').replace('r', ''))
        $(element).find('td').eq(0).before("<td><input type=\'checkbox\' value=\'#{id}\'></td>")

  }
  
)(ekylibre, jQuery)