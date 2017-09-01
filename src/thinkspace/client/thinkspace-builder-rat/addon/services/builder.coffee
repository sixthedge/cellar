import ember          from 'ember'
import base           from 'thinkspace-base/services/base'
import totem_messages from 'totem-messages/messages'
import ta             from 'totem/ds/associations'

###
# # builder.coffee
# - Type: **Service**
# - Package: **ethinkspace-builder-rat**
###

# Import prototype step objects for initialization
import details_step      from 'thinkspace-builder-rat/steps/details'
import content_step      from 'thinkspace-builder-rat/steps/content'
import settings_step     from 'thinkspace-builder-rat/steps/settings'
import confirmation_step from 'thinkspace-builder-rat/steps/confirmation'

import navigate          from 'thinkspace-builder-rat/services/builder/navigate'
import initialize        from 'thinkspace-builder-rat/services/builder/initialize'

export default base.extend initialize, navigate,
  # ## Properties
  current_step:       null

  current_step_index: ember.computed.reads 'current_step.index'

  lti_session: ember.inject.service()

  step_prototypes:    ember.computed -> 
    [
      details_step,
      content_step,
      settings_step,
      confirmation_step
    ]

  # ## Methods

  # Called inside each step's route to initialize the state of the steps by mapping the step prototypes into the steps map.
  # @public
  # @method launch
  # launch: ->
  #   new ember.RSVP.Promise (resolve, reject) =>
  #     @_initialize_map()

  step_details:      ember.computed -> @get('steps').findBy 'id', 'details'
  step_content:      ember.computed -> @get('steps').findBy 'id', 'content'
  step_settings:     ember.computed -> @get('steps').findBy 'id', 'settings'
  step_confirmation: ember.computed -> @get('steps').findBy 'id', 'confirmation'
  step_prototypes: ember.computed -> 
    [
      details_step,
      content_step,
      settings_step,
      confirmation_step
    ]

  transition_to_cases_show: ->
    model       = @get('model')
    route       = @get('route')
    lti_session = @get('lti_session')
    if lti_session.get('will_redirect')
      lti_query_params = lti_session.get_redirect_query_params()
      route_name       = lti_session.get('redirect_external_route')
      route.transitionToExternal route_name, { queryParams: lti_query_params }
    else
      route.transitionToExternal 'cases.show', model

  query_assignment: (id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      params = 
        id: id
      options =
        action: 'load'
        model:  ta.to_p('assignment')
        single: true

      @tc.query_action(ta.to_p('assignment'), params, options).then (assignment) =>
        resolve(assignment)

  _warn: (message) ->
    console.warn "[pe builder service] #{message}"

