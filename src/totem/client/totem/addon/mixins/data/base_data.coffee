import ember from 'ember'
import totem_scope    from 'totem/scope'
import totem_ability  from 'totem/mixins/data/ability'
import totem_metadata from 'totem/mixins/data/metadata'
import totem_queue    from 'totem/mixins/data/queue'

export default ember.Object.extend

  data_names: ['ability', 'metadata']
  source:     null

  init: ->
    @_super()
    @setup_totem_data()

  setup_totem_data: ->
    config = @get('source.totem_data_config') or {}
    unless @is_object(config)
      console.error "totem_data_config property in #{@source.toString()} must be a hash e.g. {ability: {}} not:", config
      return
    @totem_data_config = config
    @all_config        = @get_all_data_names_config()
    @include_totem_data_modules()

  include_totem_data_modules: ->
    @include_totem_data_module('ability',  totem_ability)
    @include_totem_data_module('metadata', totem_metadata)

  include_totem_data_module: (data_name, mod) ->
    mod_config = @merge_all_and_mod_configs(data_name)
    return unless mod_config
    base_name = 'totem_data'
    mod_name  = "#{base_name.classify()}#{data_name.classify()}"
    inst      = mod.create
      data_name:         data_name
      base_name:         base_name
      mod_name:          mod_name
      totem_scope:       totem_scope
      requests_queue:    totem_queue
      totem_data_config: mod_config
      totem_data:        @
    @set data_name, inst
    inst.init_values(@source)

  merge_all_and_mod_configs: (data_name) ->
    mod = @totem_data_config[data_name]
    mod = {}  if mod == true
    return null unless @is_object(mod)
    all = ember.merge({}, @all_config)
    ember.merge(all, mod)

  get_all_data_names_config: ->
    all = {}
    for key, value of @totem_data_config
      all[key] = value  unless @data_names.includes(key)
    all

  set_source_property: (prop, value={}) ->
    unless typeof(@source[prop]) == 'undefined'
      console.warn "totem_data: '#{prop}' is already defined in #{@source.toString()}.  The component's '#{prop}' property is being overwritten."
    @source.set prop, value

  define_source_property: (prop, tab_prop) ->
    path = "#{prop}.#{tab_prop}"
    if typeof(@source[tab_prop]) == 'undefined'
      ember.defineProperty @source, tab_prop, ember.computed.reads path
    else
      message =  "totem_data: '#{tab_prop}' is already defined in #{@source.toString()}.  "
      message += "Will need to use the full path '#{path}' or rename the component's '#{tab_prop}' property."
      console.warn message

  is_object: (object) ->
    return false if ember.isBlank(object)
    typeof(object) == 'object' and not ember.isArray(object)

  toString: -> 'TotemData'
