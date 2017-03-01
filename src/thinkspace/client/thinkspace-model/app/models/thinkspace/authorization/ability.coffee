import ember    from 'ember'
import ta       from 'totem/ds/associations'
import did_load from 'totem/mixins/data/did_load'

export default ta.Model.extend did_load,
  abilities: ta.attr()

  data_name: 'ability'
