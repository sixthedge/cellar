import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  init_base: ->
    @trad = @am.rad(name: 'TRAT', width_selector: '.ts-ra_admin-phase-states-content')

  willInsertElement: ->
    @am.get_trat_team_users().then (team_users) =>
      @trad.set_team_users(team_users)
      @set_ready_on()

  actions:
    validate: -> @validate()

    send_phase_states: ->
      @validate()
      @selected_send_on()
      return if ember.isPresent(@trad.errors)
      trat = @trad.get_data()
      @am.send_trat_phase_states({trat})

  validate: ->
    @trad.clear_errors()
    @trad.error 'No teams are selected.'  if ember.isBlank(@trad.get_teams())
    @trad.error 'No state selected.'      if ember.isBlank(@trad.get_phase_state())
