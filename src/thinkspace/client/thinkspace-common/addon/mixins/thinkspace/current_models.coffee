import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Mixin.create

  current_space:      null
  current_assignment: null
  current_phase:      null

  current_model: ember.computed 'current_space', 'current_assignment', 'current_phase', ->
    @get('current_phase') or @get('current_assignment') or @get('current_space') or null

  reset_models: ->
    @set_current_space(null)
    @set_current_assignment(null)
    @set_current_phase(null)

  get_current_model:      -> @get('current_model')
  get_current_space:      -> @get 'current_space'
  get_current_assignment: -> @get 'current_assignment'
  get_current_phase:      -> @get 'current_phase'

  set_current_space:      (space)      -> @set 'current_space', space
  set_current_assignment: (assignment) -> @set 'current_assignment', assignment
  set_current_phase:      (phase)      -> @set 'current_phase', phase

  set_current_models: (current_models={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      switch
        when phase = current_models.phase
          phase.get(ns.to_p 'assignment').then (assignment) =>
            assignment.get(ns.to_p 'space').then (space) =>
              @set_current_space(space)            unless @get_current_space() == space
              @set_current_assignment(assignment)  unless @get_current_assignment() == assignment
              @set_current_phase(phase)
              resolve()
            , (error) => reject(error)
          , (error) => reject(error)
        when assignment = current_models.assignment
          assignment.get(ns.to_p 'space').then (space) =>
            @set_current_phase(null)
            @set_current_space(space) unless @get_current_space() == space
            @set_current_assignment(assignment)
            resolve()
          , (error) => reject(error)
        when space = current_models.space
          @set_current_assignment(null)
          @set_current_phase(null)
          @set_current_space(space) unless @get_current_space() == space
          resolve()
        else
          @reset_all()
          resolve()
