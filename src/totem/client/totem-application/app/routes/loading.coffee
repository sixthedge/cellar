import ember from 'ember'
import config from 'totem-config/config'

# WARNING: This loading route will only be called from a promise in
#          the route's model functions e.g. model, beforeModel, afterModel.

export default ember.Route.extend

  renderTemplate: ->
    template = config.messages.loading_template if config.messages
    template = 'totem_message_outlet/loading' unless template
    @render template
