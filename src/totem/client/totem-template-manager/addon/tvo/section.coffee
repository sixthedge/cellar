import ember from 'ember'
import util  from 'totem/util'

export default ember.Object.extend

  register: (section, options) -> @tvo.set_path_value @_get_path(section), options

  ready: (section, value=true) -> @_ready(section, value)

  ready_properties: (value) -> @_ready_properties(value)

  lookup:    (section) -> @tvo.get @_get_path(section)
  actions:   (section) -> @_actions(section)
  component: (section) -> @_component(section)

  has_action:  (section, action)          -> @_has_action(section, action)
  send_action: (section, action, args...) -> @_send_action(section, action, args...)
  call_action: (section, action, args...) -> @_call_action(section, action, args...)

  register_component: (component, options={}) -> @_register_component(component, options)
  ready_component:    (component, options={}) -> @_ready_component(component, options)
  define_ready:       (component, options={}) -> @_define_ready(component, options)

  # ###
  # ### Internal.
  # ###

  _register_component: (component, options) ->
    @error "register_component first argument must be a component.", component unless util.is_component(component)
    @error "register_component options must be a hash.", options, component unless util.is_hash(options)
    section = options.section or @_component_section(component)
    @error "register_component section is blank.", component, options if ember.isBlank(section)
    options.component = component
    @register section, options

  _ready_component: (component, options) ->
    @error "set_section_ready first argument must be a component.", component unless util.is_component(component)
    @error "set_section_ready options must be a hash.", options, component unless util.is_hash(options)
    section = options.section or @_component_section(component)
    @error "set_section_ready section is blank.", component, options  unless section
    value   = if options.value == false then false else true
    @ready(section, value)

  # Create a computed property on the component that will become true when the 'tvo.section.section-name.ready' property(s) becomes true.
  # Options:
  #  ready:    default 'source'; name of the component's template attribute containing the section names to wait on ready
  #  property: default 'ready';  name of the property to define on the component
  _define_ready: (component, options) ->
    @error "define_ready first argument must be a component.", component unless util.is_component(component)
    @error "define_ready options must be a hash.", options, component unless util.is_hash(options)
    ready_watch = @ready_properties @_component_attribute(component, options.ready or 'source')
    ready_prop  = options.property or 'ready'
    if ember.isBlank(ready_watch)
      ember.defineProperty component, ready_prop, ember.computed -> true
    else
      ember.defineProperty component, ready_prop, ember.computed.and ready_watch...

  _ready: (section, value) ->
    @_setup_section(section)
    @_set_value("#{section}.ready", value)

  _ready_properties: (value) ->
    return [] unless value
    @tvo.attribute_value_array(value).map (prop) -> "tvo.section.#{prop}.ready"

  _set_value: (key, value) ->
    path = @_get_path(key)
    @tvo.set path, value
    path

  _get_path: (key) -> "#{@tvo_property}.#{key}"

  _component: (section) ->
    component = (@lookup(section) or {}).component
    @tvo.is_object_valid(component) and component

  _actions: (section, action) -> (@lookup(section) or {}).actions

  _has_action: (section, action) -> (@actions(section) or {})[action]

  _send_action: (section, action, args...) ->
    component = @component(section)
    @error "Section send action [#{action}] component not registered."  unless component
    actions     = @actions(section) or {}
    send_action = null
    for own k, v of actions
      send_action = v  if k == action
    @error "Section send action [#{action}] not found."  unless send_action
    component.send(send_action, args...)  if component and send_action

  _call_action: (section, action, args...) ->
    component = @component(section)
    @error "Section send action [#{action}] component not registered."  unless component
    actions    = @actions(section) or {}
    call_action = null
    for own k, v of actions
      call_action = v  if k == action
    @error "Section get action [#{action}] not found."  unless call_action
    @error "Component does not have function [#{call_action}]."  unless component[call_action] and typeof(component[call_action]) == 'function'
    component[call_action](args...)

  _setup_section: (section) ->
    path = @_get_path(section)
    return if @tvo.get(path)
    @_set_value(section, {})

  _component_section: (component) -> @_component_attribute(component, 'section')

  _component_attribute: (component, attr) -> component.get "attributes.#{attr}"

  error: (args...) -> util.error(@, args...)

  toString: -> 'TvoSection'
