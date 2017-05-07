import ember from 'ember'
import base  from 'thinkspace-base/services/base'
import totem_messages from 'totem-messages/messages'

###
# # builder.coffee
# - Type: **Service**
# - Package: **ethinkspace-builder-pe**
###

# Import prototype step objects for initialization
import details_step      from 'thinkspace-builder-pe/steps/details'
import content_step      from 'thinkspace-builder-pe/steps/content'
import settings_step     from 'thinkspace-builder-pe/steps/settings'
import confirmation_step from 'thinkspace-builder-pe/steps/confirmation'

import navigate          from 'thinkspace-builder-pe/services/builder/navigate'
import initialize        from 'thinkspace-builder-pe/services/builder/initialize'

export default base.extend initialize, navigate,
  # ## Properties
  current_step:       null
  current_step_index: ember.computed.reads 'current_step.index'

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
    model = @get('model')
    route = @get('route')
    route.transitionToExternal 'cases.show', model

  _warn: (message) ->
    console.warn "[pe builder service] #{message}"

