import ember from 'ember'
import util  from 'totem/util'

export default ember.Object.extend
  init: ->
    @_super(arguments...)
    @status_keys    = []
    @messages       = null
    @messages_title = null
    @is_edit        = false

  edit_on:  -> @set 'is_edit', true
  edit_off: -> @set 'is_edit', false

  set_messages_title: (title) -> @messages_title = title

  register_callback: (component, fn, options={}) ->
    @error('REGISTER_COMPONENT: first argument is not a component.', component)   unless util.is_component(component)
    @error('REGISTER_COMPONENT: second argument is not a string.', component)     unless util.is_string(fn)
    @error('REGISTER_COMPONENT: is not a component function.', fn, component)     unless util.is_object_function(component, fn)
    options.status_key    = @get_options_status_key(options) or @get_default_status_key()
    options.component     = component
    options.function_name = fn
    wrapper               = @callback_wrapper.create(options)
    @add_wrapper(wrapper)

  register_changeset: (changeset, options={}) ->
    @error('REGISTER_CHANGESET: first argument is not a changeset.', changeset) unless util.is_changeset(changeset)
    status_key = @get_options_status_key(options) or changeset.get_status_key() or @get_default_status_key()
    changeset.set_status_key(status_key) if ember.isBlank changeset.get_status_key()
    options.status_key = status_key
    options.changeset  = changeset
    wrapper            = @changeset_wrapper.create(options)
    @add_wrapper(wrapper)

  # Validate all or a key and set the results.  Does not set messages.
  # Returns [true|false].
  update: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      status_key  = @get_options_status_key(options)
      collections = @get_collections(status_key)
      @update_collection_results(collections).then =>
        resolve @collections_valid(collections)

  # Validate all changesets and callbacks and set the tvo.status.messages.
  # Returns [true|false].
  validate: ->
    new ember.RSVP.Promise (resolve, reject) =>
      collections = @get_collections()
      @update_collection_results(collections).then =>
        @set 'messages', @get_collection_messages(collections)
        resolve @collections_valid(collections)

  key_messages: (status_key) -> @get_collection(status_key).messages
  key_results:  (status_key) -> @get_collection(status_key).results

  # ###
  # ### Utility Helpers.
  # ###

  message_ordered_list: (title='', messages, {ol_class='', li_class='', ol_style='list-style: decimal inside;', li_style='margin-left: 1em;'}={}) ->
    return null if ember.isBlank(messages)
    html  = "<ol class='#{ol_class}' style='#{ol_style}'>#{title}"
    html += "<li class='#{li_class}' style='#{li_style}'>#{message}</li>" for message in ember.makeArray(messages)
    (html + '</ol>').htmlSafe()

  # ###
  # ### Internal Helpers.
  # ###

  get_value: (key)        -> @tvo.get_path_value @get_path(key)
  set_value: (key, value) -> @tvo.set_path_value @get_path(key), value

  get_path:  (key) -> "#{@tvo_property}.#{key}"

  get_options_status_key: (options) ->
    @error('Options is not a hash.', options) unless util.is_hash(options)
    options.key

  add_wrapper: (wrapper) ->
    key        = wrapper.status_key or @get_default_status_key()
    collection = @get_value(key)
    if ember.isBlank(collection)
      @set_value key, @status_collection.create(status_key: key)
      @status_keys.push(key)
      collection = @get_value(key)
    collection.add_wrapper(wrapper)

  update_collection_results: (collections) ->
    new ember.RSVP.Promise (resolve, reject) =>
      promises = (collection.set_results() for collection in collections)
      ember.RSVP.all(promises).then => resolve()

  get_collection_messages: (collections) ->
    messages = []
    for collection in collections
      msgs = collection.messages or null
      messages.push(msgs...) if util.is_array(msgs)
    messages

  collections_valid: (collections) ->
    invalid = ember.makeArray(collections).find (collection) -> collection.get('is_valid') != true
    ember.isBlank(invalid)

  get_collections: (status_key=null) ->
    if ember.isBlank(status_key)
      @status_keys.map (key) => @get_collection(key)
    else
      [@get_collection(status_key)]

  get_collection: (status_key) ->
    @error "Collection key is blank." if ember.isBlank(status_key)
    collection = @get_value(status_key)
    @error "Collection for key '#{status_key}' does not exist." if ember.isBlank(collection)
    collection

  get_default_status_key: (options) -> 'default'

  error: (args...) -> util.error(@, args...)

  toString: -> 'TvoStatus'

  # ###
  # ### Callback Wrapper Object.
  # ###

  callback_wrapper: ember.Object.extend
    validate: ->
      new ember.RSVP.Promise (resolve, reject) =>
        rc = @component[@function_name]()
        if util.is_promise(rc)
          rc.then (messages) =>
            @set_messages(messages)
            resolve()
        else
          @set_messages(rc)
          resolve()
    set_messages: (messages) ->
      @is_valid = ember.isBlank(messages)
      @messages = ember.makeArray(messages) unless (@is_valid or @include_messages == false)
    toString: -> 'TotemStausCallbackWrapper'

  changeset_wrapper: ember.Object.extend
    validate: ->
      new ember.RSVP.Promise (resolve, reject) =>
        @changeset.validate().then =>
          @is_valid = @changeset.get('is_valid')
          @messages = []
          if @include_messages == true
            for key, hash of @changeset.get('errors')
              msgs = (hash or {}).validation
              @messages.push(msgs...) if util.is_array(msgs)
          resolve()
    toString: -> 'TotemStausChangesetWrapper'

  # ###
  # ### Changeset Collection Object.
  # ###

  status_collection: ember.Object.extend
    init: ->
      @_super(arguments...)
      @results  = {}
      @wrappers = []
      @messages = null

    add_wrapper: (wrapper) -> @wrappers.push(wrapper)

    set_results: ->
      new ember.RSVP.Promise (resolve, reject) =>
        messages      = []
        valid_count   = 0
        invalid_count = 0
        is_valid      = true
        promises      = (wrapper.validate() for wrapper in @wrappers)
        ember.RSVP.all(promises).then =>
          for wrapper in @wrappers
            if wrapper.get('is_valid')
              valid_count += 1
            else
              is_valid       = false
              invalid_count += 1
              messages.push(wrapper.messages...) if util.is_array(wrapper.messages)
          @set 'is_valid', is_valid
          @set 'results', {valid: valid_count, invalid: invalid_count}
          @set 'messages', messages
          resolve()

    toString: -> "TvoStatusCollection-#{@status_key}"
