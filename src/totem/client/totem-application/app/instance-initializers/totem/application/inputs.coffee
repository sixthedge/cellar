import ember from 'ember'
import util  from 'totem/util'

initializer =
  name: 'totem-application-inputs'
  initialize: (instance) ->

    ember.TextField.reopen
      init: ->
        @_super(arguments...)
        if util.is_hash(@input_attributes)
          @set key, value for key, value of @input_attributes

    ember.TextArea.reopen
      init: ->
        @_super(arguments...)
        if util.is_hash(@input_attributes)
          @set key, value for key, value of @input_attributes

    ember.Checkbox.reopen
      init: ->
        @_super(arguments...)
        if util.is_hash(@input_attributes)
          @set key, value for key, value of @input_attributes

export default initializer
