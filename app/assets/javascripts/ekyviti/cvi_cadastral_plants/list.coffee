ekylibre.cviCadastralPlants ||= {}

((E, $) ->
  E.cviCadastralPlants.list = {
    init: ->
      this.manageErrorMessage()
      E.list.bindCellsClickToCenterLayer('cvi_cadastral_plants', 3, 'cvi_cadastral_plants_map')

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
) ekylibre, jQuery