import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  # ### Properties
  space:            null
  assignment_types: []

  # ### Computed properties
  has_assignment_types: ember.computed.notEmpty 'assignment_types'

  # ### Events
  init_base: ->
    @set_space().then =>
      @set_assignment_types().then =>
        @set_all_data_loaded()

  # ### Data loaders
  set_space: ->
    new ember.RSVP.Promise (resolve, reject) =>
      space_id = @get_query_param('space_id')
      if space_id
        @tc.find_record(ns.to_p('space'), space_id).then (space) =>
          @set('space', space)
          resolve()
      else
        resolve()
        # transition back to builder#new

  set_assignment_types: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.find_all(ns.to_p('assignment_type')).then (assignment_types) =>
        @set('assignment_types', assignment_types)
        resolve()

  actions:
    create: (assignment_type) ->
      options                             = {}
      options[ns.to_p('assignment_type')] = assignment_type
      options[ns.to_p('space')]           = @get('space')
      assignment = @tc.create_record ns.to_p('assignment'), options
      assignment.save().then =>
        @get('thinkspace').transition_to_route('pe.details', assignment)
