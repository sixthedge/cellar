import ember from 'ember'

export default ember.Mixin.create

  phase_settings: null

  # ### Phases show controller (for phase settings)
  # Phase settings are set via query param `phase_settings` on the casespace/phases/show controller.
  # => They're initially set via an observer and all changes are proxied to this service.
  # => The proxy is in place for components to easily inject and bind to phase settings changes here.
  get_phase_settings: -> @get 'phase_settings'
  set_phase_settings: (phase_settings) -> @set 'phase_settings', phase_settings

  set_phases_show_controller: (controller) -> @set 'phases_show_controller', controller
  get_phases_show_controller: -> @get 'phases_show_controller'

  set_phase_settings_query_params: (phase_settings) ->
    controller = @get_phases_show_controller()
    controller.set_phase_settings phase_settings
