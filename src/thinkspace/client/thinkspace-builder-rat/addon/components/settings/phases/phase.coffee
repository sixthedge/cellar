import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: 'li'

  ttz: ember.inject.service()

  options:              ['on case release', 'on previous phase submission', 'on date', 'manually']
  selected_option:      null
  last_selected_option: null
  default_option:       ember.computed.reads 'case_release_option'

  case_release_option:              'on case release'
  previous_phase_submission_option: 'on previous phase submission'
  date_option:                      'on date'
  manual_option:                    'manually'

  date_option_is_selected: ember.computed.equal 'selected_option', 'on date'

  unlock_at: ember.computed.reads 'model.unlock_at'
  due_at:    ember.computed.reads 'model.due_at'

  has_previous_phase: ember.computed.notEmpty 'previous_phase'

  remaining_options: ember.computed 'selected_option', 'has_previous_phase', ->
    remaining = ember.makeArray()
    @get('options').forEach (option) => remaining.pushObject option unless @get('selected_option') == option
    remaining.removeObject @get('previous_phase_submission_option') unless @get('has_previous_phase')
    remaining

  # ### Date / time helpers
  set_date: (context, property, date) ->
    context.set property, date.obj

  init: ->
    @_super()
    @sendAction 'register_phase', @
    model = @get 'model'
    model.get('previous_phase').then (phase) =>
      @set 'previous_phase', phase if ember.isPresent(phase)
      @initialize_select_option()

  initialize_select_option: ->
    model          = @get 'model'
    previous_phase = @get 'previous_phase'
    if model.get('unlock_at')
      @set_selected_option @get('date_option')
    else if model.get('default_state') == 'unlocked'
      @set_selected_option @get('case_release_option')
    else if ember.isPresent(previous_phase) and previous_phase.get('has_unlock_phase')
      @set_selected_option @get('previous_phase_submission_option')
    else
      @set_selected_option @get('manual_option')

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

      console.log('[CALLING SAVE] OPTIONS ARE ', phase, options, options.configuration)

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

  handle_select_option: (option) ->
    @set_selected_option option
    model = @get 'model'
    phase = @get 'previous_phase'

    switch option
      when @get('case_release_option')
        @update_phase_configuration(phase, unlock_phase: false) if ember.isPresent phase
        options = 
          unlock_at:     null
          default_state: 'unlocked'
          configuration: @get_phase_configuration(model)
        @save(model, options)

      when @get('previous_phase_submission_option')
        @update_phase_configuration(phase, unlock_phase: true) if ember.isPresent phase
        options =
          unlock_at:     null
          default_state: 'locked'
          configuration: @get_phase_configuration(model)
        @save(model, options)

      when @get('manual_option')
        @update_phase_configuration(phase, unlock_phase: false) if ember.isPresent phase
        options = 
          unlock_at:     null
          default_state: 'locked'
          configuration: @get_phase_configuration(model)
        @save(model, options)

  set_selected_option: (option) -> 
    @set 'last_selected_option', @get('selected_option')
    @set 'selected_option', option

  save_unlock_date: ->
    model = @get 'model'
    phase = @get 'previous_phase'
    @update_phase_configuration(phase, unlock_phase: false) if ember.isPresent phase
    options = 
      unlock_at:     @get 'unlock_at'
      default_state: 'locked'
      configuration: @get_phase_configuration(model)
    @save(model, options)

  actions:

    select_option: (option) ->
      @handle_select_option(option)

    cancel_select_option: ->
      @send 'select_option', @get('last_selected_option') || @get('default_option')

    select_unlock_at: (date) -> 
      model = @get('model')
      @set 'unlock_at', date
      @sendAction 'select_unlock_at', @get('unlock_at')
      @save_unlock_date()

    select_due_date: (date) -> 
      model = @get('model')
      console.log('date is ', date)
      @set('due_at', date)
      @save(model, due_at: @get('due_at'))

    reset_due_at: ->
      model = @get('model')
      @save(model, due_at: null).then (phase) =>
        @set 'due_at', phase.get('due_at')