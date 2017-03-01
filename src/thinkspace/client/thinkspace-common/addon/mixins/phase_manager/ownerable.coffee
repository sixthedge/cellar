import ember from 'ember'

export default ember.Mixin.create

  set_ownerable: (ownerable) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if ownerable
        return resolve() if @get_ownerable() == ownerable
        @totem_scope.ownerable(ownerable)
        return resolve() unless @phase_is_loaded()
        @set_all_phase_states().then => resolve()
      else
        return resolve() if @get_ownerable() == @get_current_user()
        @totem_scope.ownerable_to_current_user()
        return resolve() unless @phase_is_loaded()
        @set_all_phase_states().then => resolve()

  set_ownerable_from_phase_state: (phase_state) ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase_state.get('ownerable').then (ownerable) =>
        @set_ownerable(ownerable).then =>
          assignment = @get_assignment()
          phase      = @get_phase()
          @pmap.set_selected(ownerable, phase, phase_state)
          @pmap.set_global(ownerable, assignment, phase_state)
          resolve()
      , (error) => reject(error)

  get_ownerable:    -> @totem_scope.get_ownerable_record()
  get_current_user: -> @totem_scope.get_current_user()

  get_active_ownerable: ->
    if @has_active_addons() and @has_addon_ownerable()
      @get_active_addon_ownerable()
    else
      @get_current_user()
