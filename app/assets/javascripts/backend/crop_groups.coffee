((E, $ ) ->
  'use strict'

  toolbar = {
    init: () ->
      this.$interventionRequestBtn = $('#new-intervention-request-crop-groups')
      this.$interventionRecordBtn = $('#new-intervention-record-crop-groups')
      this.interventionRequestUrl = this.$interventionRequestBtn.prop('href')
      this.interventionRecordUrl = this.$interventionRecordBtn.prop('href')
                    
    handleBtnsDisabling: (ids) ->
      disabled = !ids.length
      toolbar.$interventionRequestBtn.toggleClass('disabled', !!disabled)
      toolbar.$interventionRecordBtn.toggleClass('disabled', !!disabled)
    
    updateBtnsHref: (ids) ->
        if ids.length > 0
          toolbar.$interventionRequestBtn
                 .prop('href', "#{toolbar.interventionRequestUrl}&crop_group_ids=#{ids}")
          toolbar.$interventionRecordBtn
                 .prop('href', "#{toolbar.interventionRecordUrl}&crop_group_ids=#{ids}")
        else
          toolbar.$interventionRequestBtn.prop('href', toolbar.interventionRequestUrl)
          toolbar.$interventionRecordBtn.prop('href', toolbar.interventionRecordUrl)
  }

  list = {
    getSelectedIds: () ->
      selectedCropGroups = $('input[data-list-selector]:checked').filter ->
                             /\d/.test($(this).data('list-selector'))
      selectedCropGroupIds = selectedCropGroups.map ->
                              $(this).data('list-selector')
                            .toArray()
  }

  $(document).ready ->
    toolbar.init() if $('#crop_groups-list').length > 0
  
  $(document).on 'change', '#crop_groups-list input[data-list-selector]', ->
    selectedIds = list.getSelectedIds()
    toolbar.handleBtnsDisabling(selectedIds)
    toolbar.updateBtnsHref(selectedIds)

  form = {
    selectedTarget: () -> $("input[type=radio][name='crop_group[target]']:checked")[0].value
    handleRadioButonsState: () ->
      selected_crop_count = $(".nested-fields input[name^='crop_group[items_attributes]'][name$='[crop_id]']").toArray().filter( (input) -> input.value != "").length
      $radio_buttons = $("input[type=radio][name='crop_group[target]']:not(:checked)")
      if selected_crop_count > 0
        $radio_buttons.prop('disabled', true)
      else
        $radio_buttons.attr('disabled', false)

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

  $(document).ready ->
    if $('.edit_crop_group').length > 0
      form.handleRadioButonsState()
      form.updateCropTypes()
      form.updateCropScopes()

  $(document).on "change", "input[type=radio][name='crop_group[target]']", () ->
    form.updateCropTypes()
    form.updateCropScopes()

  $(document).on 'cocoon:after-insert','.crop-group-item-fields', () ->
    form.updateCropTypes()
    form.updateCropScopes()

  $(document).on "selector:change", '[id^="crop_group_items_attributes_"][id$="_crop_id"]', () ->
    form.handleRadioButonsState()
    
  $(document).on "cocoon:after-remove", '.crop-group-item-fields', () ->
    form.handleRadioButonsState()
    
) ekylibre, jQuery
