import ember from 'ember'
import util  from 'totem/util'
import tvo_value    from '../tvo/value'
import tvo_hash     from '../tvo/hash'
import tvo_status   from '../tvo/status'
import tvo_template from '../tvo/template'
import tvo_section  from '../tvo/section'

# Instantiate a 'tvo' on any enmber object with this mixin.
# When creating a new 'tvo', the 'tvo_properties' can be overriden (e.g. add new objects, change objects created, etc.).
#   Example: another_tvo = ember.Object.extend(m_tvo).create(tvo_properties: [{property: 'status'}])  #=> only tvo with status object
# By default is mixed into this addon's 'tvo' service.

export default ember.Mixin.create

  init: ->
    @_super(arguments...)
    @clear()

  regenerate_view: null  # value does not change but observers can watch for a notifyPropertyChange (via 'tvo.regenerate()') and regenerate their views
  show_errors:     false

  regenerate: -> @notifyPropertyChange 'regenerate_view'

  clear: -> @_clear()

  get_path_value: (path)        -> @get path
  set_path_value: (path, value) -> @set path, value

  show_errors_on:  -> @set 'show_errors', true
  show_errors_off: -> @set 'show_errors', false

  # ###
  # ### Common Helpers.
  # ###

  guid_for: (source) -> ember.guidFor(source) or 'bad_guid'

  generate_guid: -> ember.generateGuid()

  tag_attribute_hash: ($tag) ->
    hash            = {}
    attrs           = $tag.prop('attributes') or []
    hash[attr.name] = attr.nodeValue  for attr in attrs
    hash

  tag_kind:  ($tag) -> $tag.prop('tagName').toLowerCase() # e.g. input, textarea, div, etc.
  tag_name:  ($tag) -> $tag.attr('name')
  tag_title: ($tag) -> $tag.attr('title')
  tag_type:  ($tag) -> $tag.attr('type')
  tag_class: ($tag) -> $tag.attr('class') or ''
  tag_value: ($tag) -> $tag.attr('value') or null

  component_bind_properties: (path, hash) ->
    keys = []
    keys.push key for own key of hash
    bind = ''
    return bind if ember.isBlank(keys)
    bind += " #{key}=tvo.#{path}.#{key}"  for key in keys
    bind

  add_property: (options) -> @_add_property(options)

  stringify: (hash) -> JSON.stringify(hash)

  attribute_value_array: (value) -> value and value.split(' ').map (part) -> part.trim()

  is_object_valid: (object) -> object and (not object.get('isDestroyed') and not object.get('isDestroying'))

  # ###
  # ### Internal.  Use with caution if call outside of above functions.
  # ###

  _get_tvo_value:    -> tvo_value
  _get_tvo_hash:     -> tvo_hash
  _get_tvo_section:  -> tvo_section
  _get_tvo_status:   -> tvo_status
  _get_tvo_template: -> tvo_template

  # Array of hashes. Keys:
  #   property:    [string] the property name of the object's instance set on this object
  #   class:       [object] object class to create an instance and set on @[property]; uses object.create() e.g. an ember.Object.extend()
  #   create_once: [true|false] default false; the object instance will be created once and not be re-created on a clear()
  tvo_properties: [
    {property: 'value'}
    {property: 'hash'}
    {property: 'status'}
    {property: 'template'}
    {property: 'section'}
  ]

  _get_tvo_properties: -> @get 'tvo_properties'

  _reset_object: (options={}) ->
    @_error "Reset object options must be a hash.", options unless util.is_hash(options)
    prop = options.property
    @_error "Reset 'options.property' is not a string.", options unless util.is_string(prop)
    if options.create_once == true
      @_create_object(options)  unless @get(prop)  # only do once per tvo
    else
      @_destroy_object(prop)
      @_create_object(options)

  _destroy_object: (prop) ->
    obj = @get(prop)
    obj.destroy()  if obj

  _create_object: (options) ->
    prop  = options.property
    klass = options.class or @_get_object_class(prop)
    @set prop, klass.create
      tvo:          @
      tvo_property: prop

  _get_object_class: (prop) ->
    fn = "_get_tvo_#{prop}"
    @_error "Property value '#{prop}' does not have an object class." unless util.is_object_function(@, fn)
    @[fn]()

  _clear: ->
    @show_errors_off()
    @_reset_object(obj) for obj  in (@_get_tvo_properties() or [])
    @_destroy_added_properties()

  # Property will exists until the next tvo.clear().
  added_properties: null
  _get_added_properties: -> @get 'added_properties'
  _add_property: (options) ->
    added = ember.makeArray @_get_added_properties()
    added.push(options.property)
    @set 'added_properties', added
    @_create_object(options)
  _destroy_added_properties: ->
    for prop in (@_get_added_properties() or [])
      @_destroy_object(prop)
      delete(@[prop])
    @set 'added_properties', null

  _error: (args...) -> util.error(@, args...)

  toString: -> 'TemplateValueObject'
