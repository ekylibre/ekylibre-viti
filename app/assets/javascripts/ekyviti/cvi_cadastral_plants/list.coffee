ekylibre.cviCadastralPlants ||= {}

((E, $) ->
  E.cviCadastralPlants.list = {
    init: ->
      this.manageErrorMessage()
      E.list.bindCellsClickToCenterLayer('cvi_cadastral_plants', 5, 'cvi_cadastral_plants')

    manageErrorMessage: ->
      if $("tr.invalid").length > 0 and $('#error').children().length == 0
        $('#error').append(E.templates.invalidCviCadastralPlantMessage())
  }

  $(document).ready ->
    if $('[id^=cvi_cadastral_plants].active-list').length > 0
      E.cviCadastralPlants.list.init()
  
  $(document).on 'list:page:change', ->
    if  $('[id^=cvi_cadastral_plants].active-list').length > 0
      E.cviCadastralPlants.list.init()

  $(document).on 'click','[id^=cvi_cadastral_plants] [data-cancel-list-form]', ->
    E.list.render()
) ekylibre, jQuery