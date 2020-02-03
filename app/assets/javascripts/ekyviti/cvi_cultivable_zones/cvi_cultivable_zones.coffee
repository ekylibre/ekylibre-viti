ekylibre.cviCultivableZones ||= {}

((E, $) ->
  $(document).ready ->
    
    return if $('[id^=cvi_cultivable_zones].active-list').length == 0
    
    E.cviCultivableZones.list.init()

    $(document).on E.Events.Map.edit.change, (e, obj) ->
      E.cviCultivableZones.editForm.update(obj)
    
    $(document).on 'click','[data-cancel-list-map-form]', ->
      id = parseInt(this.dataset.id)
      E.cviCultivableZones.editForm.cancel(id)
      
  $(document).on 'list:page:change', ->
    if  $('[id^=cvi_cultivable_zones].active-list').length > 0
      E.cviCultivableZones.list.init()


)(ekylibre, jQuery)