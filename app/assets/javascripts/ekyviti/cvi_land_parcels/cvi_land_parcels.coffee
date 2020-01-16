ekylibre.cviLandParcels ||= {}

((E, $) ->
  $(document).ready ->
    E.cviLandParcels.list.init()
    E.cviLandParcels.list.bindEditMultipleButton()

    $(document).on E.Events.Map.split.change, (e, obj) ->
      splitForms = E.cviLandParcels.splitForm
      splitFromCount = splitForms.count
      vine_variety_id = $('#cvi_land_parcel_vine_variety_id').attr('value')
      old = obj.old
      old.vineVarietyId = vine_variety_id
      
      if $('.edit-form .instructions').length == 1
        $('.edit-form .instructions').hide()
      
      if splitFromCount != obj.new.length
        splitForms.update(old, obj.new)
      else
        splitForms.update_values(obj.new)

    $(document).on E.Events.Map.edit.change, (e, obj) ->
      E.cviLandParcels.editForm.update(obj)
  
  $(document).on 'list:page:change', ->
    E.cviLandParcels.list.init()

  $(document).on 'dialog:show', ->
    if $("select#cvi_land_parcel_state").length > 0
      E.cviLandParcels.editForm.init()

)(ekylibre, jQuery)