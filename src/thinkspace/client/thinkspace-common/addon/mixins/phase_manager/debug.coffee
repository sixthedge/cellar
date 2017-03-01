import ember from 'ember'

export default ember.Mixin.create

  debug_ownerable: (text='') ->
    ownerable = @get_ownerable()
    unless ownerable
      console.warn text + 'ownerable is blank'
      return
    if ownerable and @totem_scope.ownerable_is_type_user()
      console.info "#{text}[user: #{ownerable.get('first_name')}] ownerable:", ownerable.toString()
    else
      console.info "#{text}[team: #{ownerable.get('title')}] ownerable:", ownerable.toString()

  debug_phase_states: ->
    assignment = @get_assignment()
    ownerable  = @get_ownerable()
    console.warn '-------------------------------------------------'
    console.info 'ownerable:', ownerable
    console.info 'assignment:', assignment
    assignment.get(@ns.to_p 'phases').then (phases) =>
      phases.forEach (phase) =>
        console.info '......phase:', phase
        console.warn 'phase_state:', phase.get('phase_state')
      console.warn '-------------------------------------------------'
