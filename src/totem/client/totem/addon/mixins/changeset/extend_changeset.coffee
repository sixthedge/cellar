import ember from 'ember'
import util  from 'totem/util'
import totem_scope from 'totem/scope'

export default ember.Mixin.create

  extend_changeset: (changeset) ->
    changeset.extend
      is_valid:    ember.computed.reads 'isValid'
      is_invalid:  ember.computed.reads 'isInvalid'
      model:       ember.computed.reads '_content'
      show_errors: false
      first_error: false
      status_key:  null

      get_model:       -> model = @get('model'); if util.is_model(model) then model else null
      show_errors_on:  -> @set 'show_errors', true
      show_errors_off: -> @set 'show_errors', false
      first_error_on:  -> @set 'first_error', true
      first_error_off: -> @set 'first_error', false

      get_status_key:       -> @get 'status_key'
      set_status_key: (key) -> @set 'status_key', key

      has_been_saved:     -> not @has_not_been_saved()
      has_not_been_saved: -> @get('isValid') and @get('isDirty')

      set_ownerable: ->
        model     = @get_model()
        type_attr = totem_scope.get_ownerable_type_attr()
        id_attr   = totem_scope.get_ownerable_id_attr()
        model.eachAttribute (rec_attr) =>
          switch rec_attr
            when type_attr
              @set type_attr, totem_scope.get_ownerable_type()
            when id_attr
              @set id_attr, totem_scope.get_ownerable_id()

      add_model_errors: ->
        model       = @get_model()
        errors      = model.get('errors') or []
        validations = {}
        errors.forEach (error) =>
          key     = error.attribute
          message = ember.String.htmlSafe("#{key}: #{error.message}")
          (validations[key] ?= []).push(message) # combine all key messages
        value = null
        @addError(key, {value, validation}) for key, validation of validations

      toString: -> 'TotemChangeset'

      has_errors: ember.computed.notEmpty 'errors'
