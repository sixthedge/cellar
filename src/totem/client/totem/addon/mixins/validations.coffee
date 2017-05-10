import ember from 'ember'

# Mock mixin 'totem/mixins/validations' for converting to changesets.
export default ember.Mixin.create

  init: ->
    @_super(arguments...)
    return if @__has_warning()
    console.warn "[NOT IMPLEMENTED] totem/mixins/validations: #{@__get_name()}"

  validate: ->
    console.warn "[NOT IMPLEMENTED] totem/mixins/validations#validate (returning true): #{@__get_name()}"
    true

  __get_name: ->
    name = @toString().split(':').shift()
    name = "#{name} (model)" if @constructor.modelName
    name

  __has_warning: ->
    ember.__validation_warnings ?= {}
    name = @__get_name()
    return false if ember.isBlank(name)
    return true  if ember.__validation_warnings[name] == true
    ember.__validation_warnings[name] = true
    false
