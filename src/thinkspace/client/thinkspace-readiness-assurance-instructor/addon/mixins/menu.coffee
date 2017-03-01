import ember from 'ember'

export default ember.Mixin.create

  done:  'done'

  actions:
    clear:           -> @clear()
    select: (config) -> @select_action(config); return
    done:   (config) -> @select_action(config); return

  init: ->
    @_super(arguments...)
    @selected_components = []
    @ready               = false
    @selected_send       = false
    @totem_scope.authable(@get 'model')
    @inactivate_menu()
    @reset()
    @setup()
    @init_menu()

  init_menu: -> return

  reset: -> @set_ready_off(); @clear()

  clear: ->
    @inactivate_menu()
    @selected_components.clear()

  clear_except_unclearables: ->
    non_clearable_configs = @selected_components.filter (config) -> config.clearable == false
    @clear()
    return if ember.isBlank(non_clearable_configs)
    @select_action(config) for config in non_clearable_configs

  setup: ->
    default_config = @get_default_config()
    @select_action(default_config) if ember.isPresent(default_config)
    # @am.se.join_with_current_user() # TESTING ONLY

  inactivate_menu: -> ember.set(config, 'active', false) for config in @get_menu_configs()

  select_action: (config) ->
    @error 'Select action config is blank.' if ember.isBlank(config)
    if config.is_clear
      @clear()
      return
    index = @selected_components.indexOf(config)
    if index >= 0  # simulate toggle
      @selected_components.removeAt(index)
      ember.set(config, 'active', false) if config
    else
      @clear_except_unclearables() if config.clear == true
      @add_selected_config(config)
      ember.set(config, 'active', true) if config

  add_selected_config: (config) ->
    if config.top == true then @add_selected_top_config(config) else @selected_components.pushObject(config)

  add_selected_top_config: (config) ->
    configs = @selected_components.filterBy 'top', true
    first   = config.first or false
    if first or ember.isBlank(configs)
      @selected_components.unshiftObject(config)
    else
      last_top = configs.get('lastObject')
      index    = @selected_components.indexOf(last_top)
      if index >= 0 then @selected_components.insertAt(index + 1, config) else @selected_components.pushObject(config)

  get_default_config: -> (@get_menu_configs().findBy('default', true) or null)

  get_menu_configs: ->
    menu_configs = @get('menu')
    if ember.isArray(menu_configs) then menu_configs else []

  find_config: (comp, options={}) ->
    options.component = comp
    found_config = @get_menu_configs().find (config) =>
      found = true
      for key, value of options
        found = false unless config[key] == value
      found
    @error "Finding menu config for component '#{comp}' is blank with options:", options if ember.isBlank(found_config)
    found_config
