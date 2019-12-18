ekylibre.templates ||= {}

((E, $) ->
  E.templates = {
    locales: I18n.locale,
    invalidCviCadastralPlantMessage: ->
    "<div class='flash error' data-alert=''>
      <div class='icon'></div>
      <div class='message'>
        <h3>#{I18n.t( 'front-end.notifications.levels.error')}</h3>
        <p>#{I18n.t( 'front-end.notifications.messages.unvalid_cvi_cadastral_plant')}</p>
      </div>
    </div>"
    splitLandParcelForm: (oldObj, newObj) ->
      name = "#{oldObj.name}-#{newObj.num}"
      area = E.tools.formatArea(newObj.area / 10000)
      index = newObj.num

      "<div class='split-form'>
        <div> Land parcel #{index} </div>
        <div class='control-group string required'>
          <label class='string required control-label' for='new_cvi_land_parcels_#{index}_name'><abbr title='Obligatoire'>*</abbr>
            Nom
          </label>
          <div class='controls'>
            <input class='string required' type='text' value='#{name}' name='new_cvi_land_parcels[#{index}][name]' id='new_cvi_land_parcels_#{index}_name'>
          </div>
        </div>
        <div class='control-group string optional'>
          <label class='string optional control-label' for='new_cvi_land_parcels_vine_variety_#{index}_id'>Cépage</label>
          <div class='controls'>
            <input data-selector='/backend/vine_varieties/unroll' data-selector-id='new_cvi_land_parcels_vine_variety_#{index}_id' class='string optional' type='text' value='#{oldObj.vineVarietyId}' name='new_cvi_land_parcels[#{index}][vine_variety_id]' id='new_cvi_land_parcels_vine_variety_#{index}_id'>
          </div>
        </div>
        <div class='control-group string optional disabled'>
          <label class='string optional disabled control-label' for='new_cvi_land_parcels_#{index}_area'>Superficie calculée</label>
          <div class='controls'>
            <input value='#{area}' class='string optional disabled' disabled='disabled' type='text' name='new_cvi_land_parcels[#{index}][area]' id='new_cvi_land_parcels_#{index}_area'>
          </div>
        </div>
        <input type='hidden' value=#{JSON.stringify(newObj.shape.geometry)} name='new_cvi_land_parcels[#{index}][shape]' id='new_cvi_land_parcels_#{index}_shape'>
      </div>"
  }
)(ekylibre, jQuery)