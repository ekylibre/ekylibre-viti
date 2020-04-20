((E, $) ->
  'use strict'

  VINE_PRODUCTION_NATURE_ID = 154

  $(document).on "selector:change", "#activity_production_cultivable_zone_id", (event)->
    element = $(this)
    id = element.selector('value')
    map = $('#activity_production_support_shape')
    $.ajax
      url: "/backend/cultivable-zones/#{id}.json"
      success: (data, status, request) ->
        map.mapeditor('edit', data.shape, true)

  $(document).on "change", "input[type=radio][name='activity[production_cycle]']", (event)->
    production_cycle_control = $(".activity_production_campaign_period")
    if this.value == 'perennial'
      $('.perennial-production-cycle-options').show()
      return if production_cycle_control.find('abbr').length == 1
      production_cycle_control.find('label').addClass('required').append(required_indicator())
    else
      production_cycle_control.find('label').removeClass('required').find('abbr').remove()
      $('.perennial-production-cycle-options').hide()

  $(document).on "selector:change", "#activity_production_nature_id", (event)->
    $control = $('.control-group.activity_production_nature')
    $hint = $control.find("p.help-block")
    $hint.hide()

  $(document).on "selector:change selector:set", "#activity_production_nature_id", (event)->
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
        if data.started_on and data.stopped_on and !$('input#activity_production_started_on').val()
          return if $('input#activity_production_started_on').val()

          fpStartedOn = flatpickr($('input#activity_production_started_on'), options)
          fpStartedOn.setDate(data.started_on) unless $('input#activity_production_started_on').val()
          fpStartedOn.calendarContainer.classList.add('day-names-hidden','year-hidden')
          fpStoppedOn = flatpickr($('input#activity_production_stopped_on'), options)
          fpStoppedOn.setDate(data.stopped_on) unless $('input#activity_production_stopped_on').val()
          fpStoppedOn.calendarContainer.classList.add('day-names-hidden','year-hidden')
          period = new Date(data.stopped_on).getFullYear() - new Date(data.started_on).getFullYear()
          $('select#activity_production_campaign').val(if period == 1 then "at_cycle_end" else "at_cycle_start")

        if data.specie
          $.ajax
            url: "/backend/varieties/selection.json?specie=#{data.specie}"
            success: (data, status, request) ->
              cultivation_select = $("select#activity_cultivation_variety")
              cultivation_select.empty()
              $.each data.varieties, (index, variety) ->
                option = $("<option>")
                  .html(variety[0])
                  .attr("value", variety[1])
                  .appendTo(cultivation_select)

          if data.start_state_of_production == null || data.start_state_of_production.length == 0
            $('div.perennial-production-cycle-options').hide()
          else
            defaultDuration = parseInt(data.start_state_of_production.match(/^(\D*)(\d+)/)[2])
            startStateOfProductions = JSON.parse(data.start_state_of_production)
            defaultStartStateOfProduction = {}
            defaultStartStateOfProduction[defaultDuration] = startStateOfProductions[defaultDuration]
            options = ''
            for key,value of startStateOfProductions
              valueObject = {}
              valueObject[key] = value
              tlOption = I18n.t("front-end.production.start_state_of_production.#{value}")
              options += "<option value=#{JSON.stringify(valueObject)}>#{tlOption}</option>"
            $('select#activity_start_state_of_production').children('option').remove()
            $('select#activity_start_state_of_production').append(options)
            $('select#activity_start_state_of_production').val(JSON.stringify(defaultStartStateOfProduction)) unless $('select#activity_start_state_of_production').val()

          if data.life_duration
            $activity_life_duration_input = $('input#activity_life_duration')
            $('#activity_production_cycle_perennial').prop('checked', true).trigger('change')
            $activity_life_duration_input.val(data.life_duration) unless $activity_life_duration_input.val()
          else
            $('#activity_production_cycle_annual').prop('checked', true).trigger('change')

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
    production_nature_control = form.find(".activity_production_nature")
    production_nature_select = form.find("#activity_production_nature_id")
    value = select.val()
    if value is undefined or value == ""
      support_control.hide()
      support_check.val(0)
      cultivation_control.hide()
      cultivation_check.val(0)
      production_nature_control.hide()
      return

    if value == "plant_farming" || value == "vine_farming"
      production_nature_control.show()
    else
      production_nature_select.val(null)
      production_nature_control.hide()

    if value == "vine_farming"
      activity_production_selector = $('input#activity_production_nature_id')[0]
      $(activity_production_selector).selector('value', VINE_PRODUCTION_NATURE_ID)

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

  required_indicator = ->
    "<abbr title=#{I18n.t('front-end.templates.form.required')}>*</abbr>"

) ekylibre, jQuery
