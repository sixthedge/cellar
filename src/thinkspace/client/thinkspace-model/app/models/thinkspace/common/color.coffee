import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend

  title:       ta.attr('string')
  description: ta.attr('string')
  color:       ta.attr('string')