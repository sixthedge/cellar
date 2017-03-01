import ember from 'ember'

export default ember.Mixin.create 
  show_errors:    false
  errors:         null
  errors_partial: null

  has_errors:    ember.computed.gt 'errors.length', 0
  input_invalid: ember.computed 'has_errors', 'has_focused', ->
    @get('has_errors') and @get('has_focused')

  display_errors: ember.computed 'has_errors', 'input_invalid', 'show_errors', ->
    @get('input_invalid') or ( @get('show_errors') and @get('has_errors') )

  ## Make sure validation messages don't appear until the user has at least put focus on the field.
  focusOut: ->
    @set('has_focused', true)

  scroll_to_error: ember.observer 'show_errors', ->
    show_errors = @get('show_errors')
    if ember.isPresent(show_errors)
      errors = $('.totem-errors_error')
      if ember.isPresent(errors)
        top = errors.position().top
        window.scrollTo(0, top - 100) # Making an assumption here on the y offset.

  first_error: ember.computed 'errors.length', ->
    errors = @get('errors')
    return errors.get('firstObject') unless ember.isEmpty(errors)