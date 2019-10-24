# ((E, $) ->
#   'use strict'

#   $(document).ready ->
#     selectedYear = Number($("#campaign").val())
#     setWineProductionPeriod(selectedYear)

#     $("#campaign").change (event) ->
#       selectedYear = Number(this.value)
#       setWineProductionPeriod(selectedYear)

#   setWineProductionPeriod = (selectedYear) ->
#     $('span#wine-production-period').text("#{selectedYear-1}-#{selectedYear}")

#   $(document).on 'click', '.select-campaign', (e) =>
#     $('#campaign-selection').modal 'show'

# ) ekylibre, jQuery
