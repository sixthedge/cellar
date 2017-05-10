import ember from 'ember'

export default ember.Component.extend

  # # All data loaded
  # Used to determine the overall data load of a component for initial rendering.
  # TODO: Could this be refactored into `unless loading.all` or something?
  all_data_loaded: false
  set_all_data_loaded:   ->  @set 'all_data_loaded', true
  reset_all_data_loaded: ->  @set 'all_data_loaded', false

  # # Loading
  # Used to handle loading substates for a component.
  loading:         null # Set on init to an object.
  set_loading:      (type) -> @set("loading.#{type}", true)
  reset_loading:    (type) -> @set("loading.#{type}", false)

  # # Query params
  get_query_params_controller:    -> @get('query_params_controller')
  get_query_param: (param)        -> @get_query_params_controller().get(param)
  set_query_param: (param, value) -> @get_query_params_controller().set(param, value)

  # # Helpers
  is_destroyed:  -> @get('isDestroyed') or @get('isDestroying')
  get_store:     -> @totem_scope.get_store()
  get_app_route: -> @totem_messages.get_app_route()

  # # Events
  init: ->
    @_super(arguments...)
    @set('loading', new Object) # Cannot use loading: {} above or all components share the object.
    @init_base()

  init_base: -> return
