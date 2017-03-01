import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'

export default ember.Object.extend

  refresh: -> @set_data()

  unload: (unload_record=null) ->
    id = @generate_model_id(unload_record)
    if ember.isBlank(id)
      console.error "#{@mod_name}.unload could not generate an model id from:", unload_record, @get_ownerable()
      return
    record = @find_store_record_by_id(id)
    return unless ember.isPresent(record)
    record.unloadRecord()

  # ###
  # ### Private.
  # ###

  init_values: (source) ->
    unless @is_object(source)
      console.error "#{@mod_name}: init_values source is not not an object:", source
      return
    @set_source(source)
    @source_name = source.toString()
    @add_current_user_observer()  if @totem_data_config.current_user_observer == true
    @unload()                     if @totem_data_config.unload == true

  set_data: -> console.error "#{@mod_name}: 'set_data' function not implemented."

  # ###
  # ### Current User Observer.
  # ###

  # Add a current user observer if specified in the options.
  add_current_user_observer: -> @addObserver 'totem_scope.current_user', @, 'current_user_switch'

  current_user_switch: ->
    ember.run.next =>
      return if ember.isBlank @get_current_user()
      @refresh()

  # ###
  # ### Get Data.
  # ###

  get_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @resolve_source_model().then =>
        if @is_record @get_source_model()
          @get_store_record_data().then (data) =>
            resolve(data)
        else
          @get_store_value_data().then (data) =>
            resolve(data)

  resolve_source_model: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get_source_model()
      return resolve(model) unless @is_promise model
      model.then (resolved) =>
        @set_resolved_model resolved
        resolve(resolved)

  get_store_record_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      id = @generate_model_id()
      @get_store_record_data_by_id(id).then (data) =>
        fn     = "add_#{@data_name}"
        record = @get_source_model()
        if @is_object(data)
          @call_object_function(record, fn, data).then =>
            resolve(data)
        else
          value = @get_ajax_source_property()
          return resolve({}) if ember.isBlank(value)
          @get_ajax_data(id).then (data) =>
            return resolve(null)  if ember.isBlank(data)
            @call_object_function(record, fn, data).then (data) =>
              @add_store_record(id, data)
              resolve(data)

  get_store_value_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      value = @get_ajax_source_property()
      return resolve({}) if ember.isBlank(value)
      id = @generate_value_id(value)
      @get_store_record_data_by_id(id).then (data) =>
        return resolve(data)  if @is_object(data)
        @get_ajax_data(id).then (data) =>
          return resolve(null)  if ember.isBlank(data)
          @add_store_record(id, data)
          resolve(data)

  get_ajax_data: (id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      value = @get_ajax_source_property()
      return resolve(null) if ember.isBlank(value)
      @send_ajax_request(id).then (data) =>
        resolve(data)

  get_store_record_data_by_id: (id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null) if ember.isBlank(id)
      record = @find_store_record_by_id(id)
      if record
        prop = @get_data_property()
        data = record.get(prop)
        if @is_object(data)
          resolve ember.merge {}, data
        else
          resolve(null)
      else
        resolve(null)

  generate_model_id: (record=null) ->
    model     = record or @get_source_model()
    ownerable = @get_ownerable()
    return null unless ( @is_record(model) and @is_record(ownerable) )
    model_id       = model.get('id')
    model_type     = @get_record_type(model)
    ownerable_id   = ownerable.get('id')
    ownerable_type = @get_record_type(ownerable)
    "#{model_type}.#{model_id}::#{ownerable_type}.#{ownerable_id}"

  generate_value_id: (value) ->
    ownerable      = @get_ownerable()
    ownerable_id   = ownerable.get('id')
    ownerable_type = @get_record_type(ownerable)
    "#{value}::#{ownerable_type}.#{ownerable_id}"

  add_store_record: (id, data) ->
    record = @find_store_record_by_id(id)
    if ember.isPresent(record)
      @delete_queue_request(id)
      return
    type    = @get_model_type()
    # record = {id: id, "#{@get_data_property()}": data}
    # @get_store().push(type, record)
    record  = {id: id, type: type, attributes: {"#{@get_data_property()}": data}}
    payload = {data: [record]}
    @get_store().pushPayload(payload)
    @delete_queue_request(id)

  find_store_record_by_id: (id) ->
    type = @get_model_type()
    @get_store().peekRecord(type, id)

  # ###
  # ### Send Ajax Request
  # ###

  send_ajax_request: (id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve(null)  if @queue_request(id)
      model     = @get_source_model()
      ownerable = @get_ownerable()
      type      = @get_model_type()
      value     = @get_ajax_source_property()
      method    = @get_ajax_method_property()
      query     =
        model:  type
        verb:   'get'
        action: @data_name.pluralize()
        data:
          auth:
            ownerable_id:   ownerable.get('id')
            ownerable_type: @get_record_type(ownerable)
            source:         value   if @is_string(value)
            source_method:  method  if @is_string(method)
      if @is_record(model)
        auth = query.data.auth
        auth.model_id   = model.get('id')
        auth.model_type = @get_record_type(model)
      ajax.object(query).then (payload) =>
        resolve(payload)

  queue_request: (id) ->
    queue = @get_requests_queue()
    return false if ember.isBlank(queue)
    queue.queue_request(@get_source(), @data_name, id)

  delete_queue_request: (id) ->
    queue = @get_requests_queue()
    return false if ember.isBlank(queue)
    queue.delete_queue_request(@data_name, id)

  get_requests_queue: -> @get('requests_queue')

  # ###
  # ### Call Object Function.
  # ###

  # Caution: When mutiple ajax requests are made for the same 'data_name' and 'id', only the
  # source's callback that initiated the ajax request will have the correct 'data' as the argument.
  # When handling multiple requests and the data is required, should add a source 'observer' instead.
  call_source_callback: (data) ->
    new ember.RSVP.Promise (resolve, reject) =>
      fn = @get_source_ajax_callback()
      @call_object_function(@get_source(), fn, data).then => resolve()

  # The object's function must modify the 'data' value directly.
  # e.g. no return value is passed back to the caller.
  call_object_function: (object, fn, data) ->
    new ember.RSVP.Promise (resolve, reject) =>
      if @is_fn(object[fn])
        response = object[fn](data, @)
        if @is_object(response) and @is_fn(response.then)
          response.then =>
            resolve(data)
        else
          resolve(data)
      else
        resolve(data)

  # ###
  # ### Process Data Name.
  # ###

  process_source_data: ->
    return false if @source_is_destroyed()
    source = @get_source()
    return false if source.get("#{@base_name}_module_only") == true
    return false if source.get("#{@base_name}_#{@data_name}_module_only") == true
    true

  # ###
  # ### Helpers.
  # ###

  get_store:                -> @totem_scope.get_store()
  get_current_user:         -> @totem_scope.get_current_user()
  get_ownerable:            -> @totem_scope.get_ownerable_record()
  get_record_type: (record) -> @totem_scope.get_record_path(record)

  get_model_type:     -> ns.to_p(@data_name)
  get_data_property:  -> @data_name.pluralize()

  get_source:          -> @get 'source_component'
  set_source: (source) -> @set 'source_component', source

  get_resolved_model:         -> @get 'resolved_model'
  set_resolved_model: (model) -> @set 'resolved_model', model

  get_ajax_source_property:  -> @totem_data_config.ajax_source
  get_ajax_method_property:  -> @totem_data_config.ajax_method
  get_source_ajax_callback:  -> @totem_data_config.callback
  get_source_model_property: -> @totem_data_config.model or 'model'
  source_is_destroyed:       -> @get_source().get('isDestroyed') or @get_source().get('isDestroying')

  get_source_model: ->
    source = @get_source()
    return source if @is_record(source)
    resolved = @get_resolved_model()
    return resolved if @is_record(resolved)
    source.get @get_source_model_property()

  get_object_keys: (object) -> Object.keys(object)

  is_record: (model) -> model and (model instanceof ds.Model)
  is_promise: (model) -> model and (model instanceof ds.PromiseObject)

  is_object: (object) ->
    return false if ember.isBlank(object)
    typeof(object) == 'object' and not ember.isArray(object)

  is_string: (str) -> typeof(str) == 'string'

  is_fn: (fn) -> typeof(fn) == 'function'

  get_inverse_abilities: (abilities) ->
    inverse = {}
    @get_object_keys(abilities).map (key) => inverse[key] = !abilities[key]
    inverse

  convert_values_to: (hash, tf) ->
    value = @boolean_value(tf)
    @get_object_keys(hash).map (key) => hash[key] = value

  convert_to_boolean: (hash) ->
    @get_object_keys(hash).map (key) =>
      tf        = @boolean_value(hash[key])
      hash[key] = tf  unless hash[key] == tf

  boolean_value: (value) -> !!value

  print_header: -> console.log "#{@toString()} ->", @source_name

  print_data: (data) -> @get_object_keys(data).sort().map (key) => console.info "  #{key} = ", data[key]

  toString: -> @mod_name + ':' + ember.guidFor(@)
