import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend
  settings:     ta.attr('settings')
  configurable: ta.attr()

# TODO: REMOVE CONFIGURABLE MODEL IF THIS WORKS!!!