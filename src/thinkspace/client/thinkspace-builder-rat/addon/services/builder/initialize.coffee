import ember from 'ember'
import base  from 'thinkspace-base/services/base'
import totem_messages from 'totem-messages/messages'

###
# # initialize.coffee
# - Type: **Mixin**
# - Package: **ethinkspace-builder-rat**
###
export default ember.Mixin.create 
  ## This mixin contains the step initialization functionality for the builder service
  manager: ember.inject.service()

  launch: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @_initialize_map()

      step_prototypes = @get('step_prototypes')
      steps           = ember.makeArray()

      step_prototypes.forEach (prototype) =>
        step = @_create_step_from_prototype(prototype)
        @_write_to_map(prototype, step)
        steps.pushObject step

      @set 'steps', steps
      @initialize_steps().then =>
        @get('manager').initialize(@get('model')).then =>
          steps.forEach (step) =>
            step.set('manager_loaded', true)
          resolve()

  initialize_steps: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @_warn "you passed in both 'only' and 'except' options to initialize_steps()" if ember.isPresent(options.only) and ember.isPresent(options.except)

      only   = ember.makeArray options.only
      except = ember.makeArray options.except

      steps = @get('steps')
      steps = @intersection(steps, only) if ember.isPresent(options.only)
      steps = @difference(steps, except) if ember.isPresent(options.except)

      promises = []
      steps.forEach (step) => promises.pushObject(step.initialize()) if step.initialize?

      ember.RSVP.Promise.all(promises).then => resolve()

  get_step: (id) -> @_get_step_from_id(id)


  ##### Private

  _initialize_map: ->
    map = @get('step_map')
    if ember.isPresent map
      map.clear()
    else
      map = ember.Map.create()
    @set 'step_map', map
    return map

  _create_step_from_prototype: (prototype) ->
    step = prototype.create(container: @container)

  _write_to_map: (key, value) ->
    map = @get('step_map')
    unless map
      @_warn "Calling write_to_map(), but step_map has not yet been created."
      return null
    map.set key, value

  _get_step_from_prototype: (prototype) ->
    map = @get('step_map')
    unless map
      @_warn "Calling get_step_from_prototype(), but step_map has not yet been created."
      return null
    step = map.get(prototype)

  _get_step_from_id: (id) ->
    steps = @get('steps')
    if ember.isEmpty steps
      @_warn "Calling get_step_from_id(), but steps have not yet been created."
      return null
    steps.findBy 'id', id
