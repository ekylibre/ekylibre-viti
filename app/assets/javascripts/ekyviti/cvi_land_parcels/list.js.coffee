((E, $) ->
  E.cviLandParcels.list = {
    selectedCviLandParcels: [],

    init: ->
      E.list.bindCellsClickToCenterLayer('cvi_land_parcels', 2)
      this.addButtons()
      this.selectedCviLandParcels = []
      this.bindEditMultipleButton()
      this.bindCheckBoxes()
  
    manageButtons: ->
      $groupButton =  $('#group-cvi-land-parcels')
      $cutButton = $('#cut-cvi-land-parcel')
      $editMultipleButton = $('#edit-multiple-cvi-land-parcels')
      $editButtons = $('td > a.edit')
      selectedCviLandParcels = this.selectedCviLandParcels
      if selectedCviLandParcels.length == 1
        $editButtons.removeClass("disabled-link")
        $groupButton.attr("disabled", true)
        $cutButton.removeAttr('disabled')
        $editMultipleButton.attr("disabled", true)
        
        params = selectedCviLandParcels[0]
        $cutButton.attr(href: "/backend/cvi_land_parcels/#{params}/pre_split")
        
      else if selectedCviLandParcels.length == 0
        $editButtons.removeClass("disabled-link")
        $groupButton.attr("disabled", true)
        $cutButton.attr("disabled", true)
        $editMultipleButton.prop( "disabled", true )
      else
        $editButtons.addClass("disabled-link")
        $groupButton.removeAttr('disabled')
        $cutButton.attr("disabled", true)
        $editMultipleButton.removeAttr('disabled')
        params = selectedCviLandParcels.map (id) ->
          "cvi_land_parcel_ids[]=#{id}"
        .join('&')
        $groupButton.attr(href: "/backend/cvi_land_parcels/group?#{params}")

    render: ->
      E.list.render()
      $('.btn-container a').attr("disabled", false)
    
    getRow: (id) ->
      return (
        {
          id: id
          designation_of_origin_id: $("#r#{id} > td.c5")
          vine_variety_id: $("#r#{id} > td.c6")
          planting_campaign: $("#r#{id} > td.c10")
          inter_vine_plant_distance_value: $("#r#{id} > td.c11")
          inter_row_distance_value: $("#r#{id} > td.c12")
          state: $("#r#{id} > td.c13")
        }
      )
    bindCheckBoxes: ->
      $(document).on "click", "#cvi_land_parcels-list td>input[data-list-selector]", (event) ->
        list = E.cviLandParcels.list
        $list = $(this.closest('*[data-list-source]'))
        E.cviLandParcels.list.selectedCviLandParcels = Object.keys($list.prop('selection'))

        list.manageButtons()

        id = parseInt(this.value)
        layer = E.map.select id , false, 'cvi_land_parcels'
        unless this.checked 
          layer.setStyle(fillOpacity: 0)
          if list.selectedCviLandParcels.length == 0
            E.map.setView()
          return

        layer.setStyle(fillOpacity: 0.3)
        if list.selectedCviLandParcels.length == 1
          E.map.centerLayer(id, true, "cvi_land_parcels") if list.selectedCviLandParcels.length == 1
        else if list.selectedCviLandParcels.length == 2
          E.map.setView()

    addButtons: ->
      $(E.templates.cviLandParcelsButtons()).insertBefore('#cvi_land_parcels-list tr:first')
    
    formatUngroupableRow: (ids, attributes) ->
      list = this
      rows = ids.map (id) ->
        list.getRow(id)
      for row in rows
        for attribute in attributes
          row[attribute].addClass('invalid')

    disable: ->
      $('.btn-container a').attr("disabled", true)
      $('input[type=checkbox]').attr('disabled', true)
      E.list.disable()
    
    bindEditMultipleButton: ->
      list = this
      $editMultipleButton = $('#edit-multiple-cvi-land-parcels')
      $editMultipleButton.on "click", ->
        params = list.selectedCviLandParcels.map (id) ->
              "ids[]=#{id}"
            .join('&')
        ekylibre.dialog.open "/backend/cvi_land_parcels/edit_multiple?#{params}",
          returns:
            success: (frame, data, status, request) =>
              frame.dialog "close"
            invalid: (frame, data, status, request) ->
              frame.html request.responseText
              frame.trigger('dialog:show')

  }
  
)(ekylibre, jQuery)