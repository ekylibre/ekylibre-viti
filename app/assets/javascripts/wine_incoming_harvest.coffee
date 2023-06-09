((E, $) ->

  E.wineIncomingHarvest =
    fillAreaValue: ($container, plantId, percentage) ->
      $target = $container.find('span.net-harvest-area')
      return @._clearAreaValue($target) unless plantId && percentage

      $.getJSON '/backend/wine_incoming_harvest_plants/net_harvest_area', plant_id: plantId, percentage: percentage, (data) =>
        $target.html(data.net_harvest_area)

    _clearAreaValue: ($target) ->
      $target.html('')


  $(document).on 'selector:change', "[data-selector-id='wine_incoming_harvest_plant_plant_id']", ->
    plantId = $(this).selector('value')
    percentage = $(this).closest('.nested-fields').find('input.harvest-percentage-received').val()
    E.wineIncomingHarvest.fillAreaValue($(this).closest('.nested-fields'), plantId, percentage)


  $(document).on 'change input', 'input.harvest-percentage-received', ->
    percentage = $(this).val()
    plantId = $(this).closest('.nested-fields').find("[data-selector-id='wine_incoming_harvest_plant_plant_id']").first().selector('value')
    E.wineIncomingHarvest.fillAreaValue($(this).closest('.nested-fields'), plantId, percentage)

  return
) ekylibre, jQuery
