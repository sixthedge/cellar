import ember from 'ember'
import ta from 'totem/ds/associations'

export default ta.Model.extend
  token:                 ta.attr('string')
  email:                 ta.attr('string')
  password:              ta.attr('string')
  password_confirmation: ta.attr('string')