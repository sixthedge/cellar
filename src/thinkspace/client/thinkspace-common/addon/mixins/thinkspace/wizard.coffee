import ember from 'ember'

export default ember.Mixin.create

  enable_wizard_mode:  -> @hide_toolbar()
  disable_wizard_mode: -> @show_toolbar()

  scroll_to_top: ->
    $('#content-wrapper').scrollTop(0)
    $(window).scrollTop(0)

  current_transition: null
  get_current_transition:              -> @get 'current_transition'
  set_current_transition: (transition) -> @set 'current_transition', transition

  transition_is_for: (transition, match=null) ->
    return false unless (transition and match)
    target = transition.targetName or ''
    target.match(match)
