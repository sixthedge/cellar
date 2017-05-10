import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # tagName: 'li'

  ttz: ember.inject.service()

  unlock_at: ember.computed.reads 'model.unlock_at'
  due_at:    ember.computed.reads 'model.due_at'

  irat_type: 'irat'
  trat_type: 'trat'

  type:      null

  # ### Date / time helpers
  set_date: (context, property, date) ->
    context.set property, date.obj
  
  get_phase_configuration: (phase) ->
    configuration =
      max_score:              phase.get('max_score')
      configuration_validate: phase.get('configuration_validate')
      team_based:             ember.isPresent(phase.get('team_set_id')) or ember.isPresent(phase.get('team_category_id'))
      auto_score:             phase.get('has_auto_score')
      complete_phase:         phase.get('has_complete_phase')
      unlock_phase:           phase.get('has_unlock_phase')

  update_phase_configuration: (phase, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      configuration = @get_phase_configuration(phase)
      for key, value of options
        configuration[key] = value if ember.isPresent(configuration[key])
      @save(phase, configuration: configuration).then (saved_phase) =>
        resolve saved_phase

  save: (phase, options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      ns_phase      = ns.to_p('phase')
      store         = @totem_scope.get_store()

      params        = 
        id:     phase.get('id')
        data: 
          id:               phase.get('id')
          attributes: 
            default_state: if options.hasOwnProperty('default_state') then options.default_state else phase.get('default_state')
            unlock_at:     if options.hasOwnProperty('unlock_at') then options.unlock_at else phase.get('unlock_at')
            due_at:        if options.hasOwnProperty('due_at') then options.due_at  else phase.get('due_at')
        configuration: if options.configuration then options.configuration else @get_phase_configuration(phase)

      settings = 
        model:  ns.to_p('phase')
        verb:   'PATCH'
        single: true

      params.data.attributes.due_at = options.due_at if options.hasOwnProperty('due_at')

      @tc.query_action(ns.to_p('phase'), params, settings).then (phase) =>
        resolve(phase)

  save_unlock_date: ->
    model = @get 'model'
    options = 
      unlock_at:     @get 'unlock_at'
      default_state: 'locked'
      configuration: @get_phase_configuration(model)
    @save(model, options)

  save_assignment_unlock: (date) ->
    step = @get('step')
    step.set('changeset.release_at', date)
    step.save()

  save_assignment_due_at: (date) ->
    step = @get('step')
    step.set('changeset.due_at', date)
    step.save()

  actions:

    select_option: (option) ->
      @handle_select_option(option)

    select_unlock_at: (date) -> 
      model = @get('model')
      @set 'unlock_at', date
      @sendAction 'select_unlock_at', @get('unlock_at')
      @save_assignment_unlock(date) if @get('type') == @get('irat_type')
      @save_unlock_date()

    select_due_date: (date) -> 
      model = @get('model')
      @set('due_at', date)
      @save_assignment_due_at(date) if @get('type') == @get('trat_type')
      @save(model, due_at: @get('due_at'))

    reset_due_at: ->
      model = @get('model')
      @save(model, due_at: null).then (phase) =>
        @set 'due_at', phase.get('due_at')