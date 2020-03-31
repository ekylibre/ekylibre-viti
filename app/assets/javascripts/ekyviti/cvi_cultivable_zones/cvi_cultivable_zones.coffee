ekylibre.cviCultivableZones ||= {}

((E, $) ->
  $(document).ready ->
    return if $('[id^=cvi_cultivable_zones].active-list').length == 0
    
    E.cviCultivableZones.list.init()

  $(document).on "ekylibre:map:events:edit:change", (e, obj) ->
    return if $('[id^=cvi_cultivable_zones].active-list').length == 0
    E.cviCultivableZones.editForm.update(obj)
  
  $(document).on 'click','[id^=cvi_cultivable_zones] [data-cancel-list-map-form]', ->
    id = parseInt(this.dataset.id)
    E.cviCultivableZones.editForm.cancel(id)
      
  $(document).on 'list:page:change', ->
    if  $('[id^=cvi_cultivable_zones].active-list').length > 0
      E.cviCultivableZones.list.init()


)(ekylibre, jQuery)