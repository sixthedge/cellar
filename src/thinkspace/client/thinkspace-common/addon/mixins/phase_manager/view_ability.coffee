import ember from 'ember'

export default ember.Mixin.create

  set_totem_scope_view_ability: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @has_active_addons()  # if addon active, the addon sets the view only value
      phase       = @get_phase()
      ownerable   = @get_ownerable()
      phase_state = @pmap.get_selected(ownerable, phase)
      unless phase_state
        @set_view_only_on()
        return resolve()
      if phase_state.get('is_view_only')
        @set_view_only_on()
        return resolve()
      if phase.is_team_ownerable()
        @set_totem_scope_view_ability_team_ownerable().then => return resolve()
      else
        @set_view_only_off()
        resolve()

  set_totem_scope_view_ability_team_ownerable: ->
    new ember.RSVP.Promise (resolve, reject) =>
      phase         = @get_phase()
      map_ownerable = @get_ownerable()
      phase_state   = @pmap.get_selected(map_ownerable, phase)
      if phase_state
        phase_state.get('ownerable').then (ownerable) =>
          if ownerable and ownerable.get('is_member')
            @set_view_only_off()
          else
            @set_view_only_on()
          resolve()
      else
        @set_view_only_on()
        resolve()
