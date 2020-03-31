ekylibre.cviLandParcels ||= {}

((E, $) ->
  $(document).ready ->
    return if $('[id^=cvi_land_parcels].active-list').length == 0
    E.cviLandParcels.list.init()

  $(document).on "ekylibre:map:events:split:change", (e, obj) ->
    return if $('[id^=cvi_land_parcels].active-list').length == 0

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

  $(document).on "ekylibre:map:events:edit:change", (e, obj) ->
    return if $('[id^=cvi_land_parcels].active-list').length == 0
    E.cviLandParcels.editForm.update(obj)
      
  $(document).on 'click','[id^=cvi_land_parcels] [data-cancel-list-map-form]', ->
    id = parseInt(this.dataset.id)
    E.cviLandParcels.editForm.cancel(id)

  $(document).on 'click','[id^=cvi_land_parcels] [data-cancel-list-map-split-form]', ->
    id = parseInt(this.dataset.id)
    E.cviLandParcels.splitForm.cancel(id)

  $(document).on 'list:page:change', ->
    return if $('[id^=cvi_land_parcels].active-list').length == 0
    E.cviLandParcels.list.init()

  $(document).on 'dialog:show', ->
    if $("select#cvi_land_parcel_state").length > 0
      E.cviLandParcels.editForm.init()

)(ekylibre, jQuery)