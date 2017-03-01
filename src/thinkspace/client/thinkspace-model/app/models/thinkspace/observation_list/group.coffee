import ember      from 'ember'
import ta         from 'totem/ds/associations'
import data_mixin from 'totem/mixins/data'

export default ta.Model.extend
  title:          ta.attr 'string'
  groupable_type: ta.attr 'string'
  groupable_id:   ta.attr 'number'