ekylibre.cviCultivableZones ||= {}
ekylibre.cviCultivableZones.editForm ||= {}

((E, $) ->

  E.cviCultivableZones.editForm = {
    cancel: (record_id) ->
      E.list.render()
      E.map.edit(record_id, 'cvi_cultivable_zones', cancel: true)
    update: (record) ->
      $("input[name='cvi_cultivable_zone[shape]']").val(JSON.stringify(record.shape.geometry))
      $("input[name='cvi_cultivable_zone[area]']").val(E.tools.formatArea(record.area / 10000))
  }

)(ekylibre, jQuery)