((E, $ ) ->
  'use strict'
  E.PRODUCTS_UNROLL_URL = 
  form = {
    selectedTarget: () -> $("input[type=radio][name='crop_group[target]']:checked")[0].value
    handleRadioButonsState: () ->
      selected_crop_count = $("[name^='crop_group[items_attributes]'][name$='[crop_id]']").toArray().filter( (input) -> input.value != "").length
      $radio_buttons = $("input[type=radio][name='crop_group[target]']")
      if selected_crop_count > 0
        for input in $radio_buttons
          $(input).attr('disabled', true)
      else
        for input in $radio_buttons
          $(input).attr('disabled', false)

    updateCropTypes: () ->
      cropType = _.startCase(_.camelCase(form.selectedTarget())).replace(/ /g, '')
      for input in $('input[id^="crop_group_items_attributes_"][id$="_crop_type"]')
        $(input).val(cropType)

    updateCropScopes: () ->
      scope_name = form.selectedTarget() + 's'
      productsUnrollUrl = "/backend/products/unroll?scope="
      for input in $('input[id^="crop_group_items_attributes_"][id$="_crop_id"]')
        $(input).attr('data-selector', productsUnrollUrl + scope_name )
  }

  $(document).on "change", "input[type=radio][name='crop_group[target]']", () ->
    form.updateCropTypes()
    form.updateCropScopes()

  $(document).on 'cocoon:after-insert', () ->
    form.updateCropTypes()
    form.updateCropScopes()

  $(document).on "selector:change", '[id^="crop_group_items_attributes_"][id$="_crop_id"]', () ->
    form.handleRadioButonsState()
    
  $(document).on "cocoon:after-remove", '#items-field', () ->
    form.handleRadioButonsState()
    
) ekylibre, jQuery
