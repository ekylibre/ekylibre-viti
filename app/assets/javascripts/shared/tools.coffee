ekylibre.tools ||= {}

((E, $) ->

  E.tools= {
    formatArea: (area) ->
      ha_area = Math.trunc(area)
      a_area = Math.trunc((area - ha_area) * 100)
      ca_area = Math.trunc((area - ha_area - a_area / 100) * 10000)
      result = "#{ha_area} ha #{a_area} a #{ca_area} ca"
  }
)(ekylibre,jQuery)