ekylibre.cviLandParcels.splitForm ||= {}
ekylibre.cviLandParcels.editForm ||= {}

((E, $) ->

  E.cviLandParcels.editForm = {
    cancel: (record_id) ->
      E.cviLandParcels.list.render()
      E.map.edit(record_id, 'cvi_land_parcels', cancel: true)
    update: (record) ->
      $("input[name='cvi_land_parcel[shape]']").val(JSON.stringify(record.shape.geometry))
      $("input[name='cvi_land_parcel[area]']").val(E.tools.formatArea(record.area / 10000))
    init: ->
      $state_select = $("select#cvi_land_parcel_state")
      $land_modification_date_input = $("div.control-group.cvi_land_parcel_land_modification_date")
      if $state_select.val() == 'planted'
        $land_modification_date_input.hide()
      $state_select.on "change", (e) ->
        if e.target.value == "removed_with_authorization"
          $land_modification_date_input.show()
        else
          $land_modification_date_input.hide()
  }
  
  E.cviLandParcels.splitForm = {
    count: 0
    update: (old, new_objects) ->
      $form = $("#edit_cvi_land_parcel_#{old.uuid} div.fieldset-fields")
      $form.find(".split-form").remove()
      this.count = new_objects.length
      for element in new_objects
        $form.append(E.ekyviti.templates.splitLandParcelForm(old , element))
      $("input[data-selector]").each ->
        $(this).selector()

    update_values: (new_objects) => 
      for element in new_objects
        index = element.num
        $("#new_cvi_land_parcels_#{index}_area").val(E.tools.formatArea(element.area / 10000))
        $("#new_cvi_land_parcels_#{index}_shape").val(JSON.stringify(element.shape.geometry))

    cancel: ->
      this.count = 0
      E.cviLandParcels.list.render()
      $.reloadCartographyMap()
  }

)(ekylibre, jQuery)