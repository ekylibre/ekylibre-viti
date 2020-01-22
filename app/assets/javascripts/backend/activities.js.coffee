((E, $) ->
  'use strict'

  $(document).on "selector:change", "#activity_production_cultivable_zone_id", (event)->
    element = $(this)
    id = element.selector('value')
    map = $('#activity_production_support_shape')
    $.ajax
      url: "/backend/cultivable-zones/#{id}.json"
      success: (data, status, request) ->
        console.log data
        map.mapeditor('edit', data.shape, true)

  $(document).on "selector:change", "#activity_production_nature_id", (event)->
    element = $(this)
    id = element.selector('value')
    options =
      locale: $('input#activity_production_started_on').attr("lang")
      dateFormat: 'Y-m-d'
      altInput: true
      altFormat: 'd-F'
    $.ajax
      url: "/backend/master_production_natures/#{id}.json"
      success: (data, status, request) ->
        fp_stared_on = $('input#activity_production_started_on').flatpickr(options)
        fp_stared_on.setDate(data.started_on)
        fp_stared_on.calendarContainer.classList.add('day-year-hidden')
        fp_stopped_on = $('input#activity_production_stopped_on').flatpickr(options)
        fp_stopped_on.setDate(data.stopped_on)
        fp_stopped_on.calendarContainer.classList.add('day-year-hidden')


  $(document).on "change keyup", ".plant-density-abacus .activity_plant_density_abaci_seeding_density_unit select", (event)->
    element = $(this)
    label = element.find('option:selected').html()
    element.closest('.plant-density-abacus').find('.seeding-density-unit').html(label)

  $(document).on "change keyup", ".plant-density-abacus .activity_plant_density_abaci_sampling_length_unit select", (event)->
    element = $(this)
    label = element.find('option:selected').html()
    element.closest('.plant-density-abacus').find('.sampling-length-unit').html(label)

  $(document).on "cocoon:after-insert", ".plant-density-abacus #items-field", (event)->
    element = $(this)
    element.closest('.plant-density-abacus').find('select').trigger('change')


  $(document).on "change keyup", ".inspection-calibration-scale .activity_inspection_calibration_scales_size_unit_name select", (event)->
    element = $(this)
    label = element.find('option:selected').html()
    element.closest('.inspection-calibration-scale').find('.scale-unit').html(label)

  $(document).on "cocoon:after-insert", ".inspection-calibration-scale #natures-field", (event)->
    element = $(this)
    element.closest('.inspection-calibration-scale').find('.activity_inspection_calibration_scales_size_unit_name select').trigger('change')


  # Set
  $(document).on "change keyup", "select[data-activity-family]", (event)->
    select = $(this)
    form = select.closest("form")
    support_check   = form.find("#activity_with_supports")
    support_select  = form.find("#activity_support_variety")
    support_control = form.find(".activity_support_variety")
    cultivation_check   = form.find("#activity_with_cultivation")
    cultivation_select  = form.find("#activity_cultivation_variety")
    cultivation_control = form.find(".activity_cultivation_variety")
    value = select.val()
    if value is undefined or value == ""
      support_control.hide()
      support_check.val(0)
      cultivation_control.hide()
      cultivation_check.val(0)
    else
      $.ajax
        url: "/backend/activities/family.json"
        data:
          name: value
        success: (data, status, request) ->
          if data.support_varieties?
            support_select.html("")
            $.each data.support_varieties, (index, item) ->
              option = $("<option>")
                .html(item.label)
                .attr("value", item.value)
                .appendTo(support_select)
            support_control.show()
            support_select.trigger("change")
            support_check.val(1)
          else
            support_control.hide()
            support_check.val(0)
          support_check.trigger("change")

          if data.cultivation_varieties?
            cultivation_select.html("")
            $.each data.cultivation_varieties, (index, item) ->
              option = $("<option>")
                .html(item.label)
                .attr("value", item.value)
                .appendTo(cultivation_select)
            cultivation_control.show()
            cultivation_select.trigger("change")
            cultivation_check.val(1)
          else
            cultivation_control.hide()
            cultivation_check.val(0)
          cultivation_check.trigger("change")


) ekylibre, jQuery
