import ember from 'ember'
import base  from 'totem-base/components/base'
import totem_data_mixin from 'totem/mixins/data'

export default base.extend totem_data_mixin,

  session:    ember.inject.service()
  thinkspace: ember.inject.service()
  tvo:        ember.inject.service()
  addons:     ember.inject.service()

  totem_data_config: ability: true, metadata: true

  tvo_titles:      null
  tvo_path:        null
  
  all_data_loaded: false
  is_loading:      false

  init: ->
    @_super(arguments...)
    @session  = @get('session')
    titles    = @get('tvo_titles')
    path      = @get('tvo_path') or null
    @tvo_path = if ember.isBlank(path) and ember.isPresent(titles) then @get('tvo').template.engine_values(titles, @) else path
    @init_base()

  init_base: -> return

  set_all_data_loaded:   -> @set 'all_data_loaded', true
  reset_all_data_loaded: -> @set 'all_data_loaded', false
  set_is_loading:        -> @set('is_loading', true)
  reset_is_loading:      -> @set('is_loading', false)

  current_models: -> @get('thinkspace')

  is_destroyed: -> @get('isDestroyed') or @get('isDestroying')

  get_store: -> @totem_scope.get_store()

  # Query param support
  get_query_params_controller:    -> @get('query_params_controller')
  get_query_param: (param)        -> @get_query_params_controller().get(param)
  set_query_param: (param, value) -> @get_query_params_controller().set(param, value)

  # Tvo Helpers.
  tvo_show_errors_on:  -> @get('tvo').show_errors_on()
  tvo_show_errors_off: -> @get('tvo').show_errors_off()
  tvo_status_validate: -> @get('tvo.status').validate()
  tvo_status_register_changeset: (args...) -> @get('tvo.status').register_changeset(args...)
  tvo_status_register_callback:  (args...) -> @get('tvo.status').register_callback(args...)
  tvo_status_messages_title:     (args...) -> @get('tvo.status').set_messages_title(args...)
  tvo_section_has_action:        (args...) -> @get('tvo.section').has_action(args...)
  tvo_section_call_action:       (args...) -> @get('tvo.section').call_action(args...)
  tvo_section_send_action:       (args...) -> @get('tvo.section').send_action(args...)
  tvo_section_define_ready:      (args...) -> @get('tvo.section').define_ready(@, args...)
  tvo_section_ready:             (args...) -> @get('tvo.section').ready_component(@, args...)
  tvo_section_register_actions:  (hash)    -> @get('tvo.section').register_component(@, actions: hash)

  get_app_route:  -> @totem_messages.get_app_route()
