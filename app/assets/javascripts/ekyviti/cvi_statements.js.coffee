((E, $) ->
  'use strict'

  $(document).ready ->
    return if $('#campaign-selection').length == 0
    
    selectedYear = Number($("#campaign").val())
    setWineProductionPeriod(selectedYear)

    $("#campaign").change (event) ->
      selectedYear = Number(this.value)
      setWineProductionPeriod(selectedYear)

    $(document).on 'click', '.select-campaign', (e) ->
      $('#campaign-selection').modal 'show'

  setWineProductionPeriod = (selectedYear) ->
    $('span#wine-production-period').text("#{selectedYear-1}-#{selectedYear}")

) ekylibre, jQuery
