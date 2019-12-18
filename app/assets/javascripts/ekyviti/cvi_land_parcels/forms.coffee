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
  }
  
  E.cviLandParcels.splitForm = {
    count: 0
    update: (old, new_objects) ->
      $form = $("#edit_cvi_land_parcel_#{old.uuid} div.fieldset-fields")
      $form.find(".split-form").remove()
      this.count = new_objects.length
      for element in new_objects
        $form.append(E.templates.splitLandParcelForm(old , element))
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
      map = E.map._cartography.map
      currentBounds = map.getBounds()
      map.remove()
      $("#face-map > div.map-fullwidth.map-halfheight > div").remove()
      $.loadMap()
      E.map._cartography.map.fitBounds(currentBounds)
  }

)(ekylibre, jQuery)