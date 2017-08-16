import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/services/base'
import totem_messages from 'totem-messages/messages'

###
# # navigate.coffee
# - Type: **Mixin**
# - Package: **ethinkspace-builder-pe**
###
export default ember.Mixin.create 
  ## This mixin contains the step navigation functionality for the builder service

  # ## Properties

  current_step: null
  current_step_index: ember.computed.reads 'current_step.index'


  # ## Setters

  set_route: (route) -> @set 'route', route
  set_model: (model) -> @set 'model', model
  set_current_step: (step) -> @set 'current_step', step

  set_current_step_from_id: (id) ->
    step = @get('steps').findBy 'id', id
    @_warn "could not find step for id: [#{id}]" unless ember.isPresent(step)
    @set_current_step(step)


  # ## Getters

  get_next_step: ->
    index = @get('current_step_index')
    @get_step_at_index(index + 1)

  get_prev_step: ->
    index = @get('current_step_index')
    @get_step_at_index(index - 1)

  get_step_at_index: (index) -> @get('steps').objectAt(index)

  get_model: -> @get('model')

  # ## Transitions

  transition_to_prev_step: (options={})->
    step = @get_prev_step()
    @transition_to_step(step, options)

  transition_to_next_step: (options={})->
    step = @get_next_step()
    @transition_to_step(step, options)

  transition_to_step: (step, options={}) ->
    route = @get('route')
    model = @get('model')

    if options.save and options.validate
      @validate_current_step().then (valid) =>
        return unless valid
        @save_current_step().then =>
          route.transitionTo step.route_path, model
    else if options.save
      @save_current_step().then =>
        route.transitionTo step.route_path, model
    else
      route.transitionTo step.route_path, model

  validate_current_step: ->
    new ember.RSVP.Promise (resolve, reject) =>
      step = @get('current_step')
      step.validate().then (valid) =>
        resolve(valid)
    
  save_current_step: ->
    new ember.RSVP.Promise (resolve, reject) =>
      step  = @get('current_step')
      model = @get('model')
      if step.save?
        step.save().then =>
          totem_messages.api_success source: @, model: model, action: 'update', i18n_path: ns.to_o('tbl:assessment', 'save')
          resolve()
        , (error) => 
          totem_messages.api_failure error, source: @, model: model, action: 'update'
          reject(error)
      else
        @_warn "step '#{step.id}' does not implement a save() function"
        resolve()
