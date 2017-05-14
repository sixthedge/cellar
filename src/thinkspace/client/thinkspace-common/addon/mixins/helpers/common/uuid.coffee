import ember from 'ember'

export default ember.Mixin.create

  uuid: ->
    'xxxxxxxx_xxxx_4xxx_yxxx_xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = Math.random() * 16 | 0
      v = if c == 'x' then r else r & 0x3 | 0x8
      v.toString 16