import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  # The changeset attribute is live updated.  This allows changeset validators to update errors on user input.
  # The @attributes are set on an instance of the ember component (i.e TextField), so should be valid attributes.
  # When either the @changeset or @attribute is blank, the calling component must handle the input value actions.

  show_errors: false  # input level flag; errors are shown if one (or more) is true: this property, 'tvo.show_errors', 'changeset.show_errors'

  # ### Template Parameters ###
  #  - When a dasherized action is added, this component will do a @sendAction(action-name, value(s)).
  #    - The action value is the input value (e.g. the user entered text), HOWEVER, the changeset attribute is already updated.
  #    - The key-up action also includes the 'event' object.
  #    - Example: component '__changeset/input' changeset=changeset attribute='title' focus-out='save_record' #=> @sendAction('focus-out', value)
  #    - A default action can be turned off by setting it to false (e.g. focus-out=false; note: this would disable the show errors check too).
  # - All of these template parameters are optional.
  changeset:                null  # [changeset]
  attribute:                null  # [string] changeset attribute updated with the input value
  attributes:               null  # [hash] input tag attributes (see: http://emberjs.com/api/classes/Ember.Templates.helpers.html)
  label:                    null  # [string] add this label before the input
  show_errors_on_focus_out: true  # [true|false] show errors on focus-out for the input
  error_class: 'has-errors'       # [string] class added (if errors) or removed (no errors) from the element selected by 'input_id'
  input_id:    ember.computed 'elementId', -> "input-#{@get('elementId')}" # [string] default is this component's elementId; element to add the error_class

  value: ember.computed
    get: -> @get_value()
    set: (key, value) ->
      @set_value(value)
      value

  default_actions:
    'focus-out': true  # defaults to true to check show errors on focus-out

  default_attributes:
    type:        'text'
    tabindex:    null
    placeholder: null

  actions:
    focus_out:      (value) -> @send_action('focus-out', value)
    focus_in:       (value) -> @send_action('focus-in', value)
    enter:          (value) -> @send_action('enter', value)
    escape_press:   (value) -> @send_action('escape-press', value)
    insert_newline: (value) -> @send_action('insert-newline', value)
    key_press:      (value) -> @send_action('key-press', value)
    key_up:  (value, event) -> @send_action('key-up', value, event)

  send_action: (action_name, args...) ->
    @handle_action(action_name, args...)
    @sendAction(action_name, args...) if util.is_string(@[action_name])

  handle_action: (action_name, args...) ->
    fn = "handle_#{action_name.underscore()}"
    @[fn](args...) if util.is_object_function(@, fn)

  handle_focus_out: (value) -> @set 'show_errors', @get('show_errors_on_focus_out') == true
 
  init: ->
    @_super(arguments...)
    @set 'input_attributes', @get_attributes()

  get_attributes: ->
    attrs          = {}
    template_attrs = if util.is_hash(@attributes) then @attributes else {}
    ember.merge(attrs, template_attrs)
    @add_attributes(attrs)
    @add_actions(attrs)
    attrs.disabled = true if @get('viewonly')
    attrs

  add_attributes: (attrs) ->
    overrides = util.hash_keys(@default_attributes)
    for attr in overrides
      val         = @get_override_value(attr, @default_attributes)
      attrs[attr] = val unless util.is_null(val)

  add_actions: (attrs) ->
    overrides = util.hash_keys(@actions)
    for attr in overrides
      action        = attr.dasherize()
      val           = @get_override_value(action, @default_actions)
      attrs[action] = attr if val == true or util.is_string(val)
      # attrs[action] = attr # TESTING ONLY - ACTIVATE ALL ACTIONS

  get_override_value: (attr, defaults={}) ->
    val = @[attr]
    val = defaults[attr] if util.is_undefined(val) # not passed as a template param; use default value
    if ember.isBlank(val) then null else val

  get_value:         -> if @has_changeset() then @changeset.get(@attribute) else null
  set_value: (value) -> if @has_changeset() then @changeset.set(@attribute, value)

  has_changeset: -> ember.isPresent(@attribute) and ember.isPresent(@changeset)

#   poll: false
#   # Some browsers do not trigger a 'change' event on the input if the field is autofilled
#   # To fully account for this issue, poll to ensure that ember can catch input changes made by autofill
#   autofill_poll: (->
#     return unless @get('poll')
#     ember.run.later @, ( =>
#       return unless ember.isPresent(@) and ember.isPresent(@$()) and @get('poll')
#       @$('input').trigger('change')
#       @autofill_poll()
#     ), 250
#   ).on('didInsertElement')
