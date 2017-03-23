import ember  from 'ember'
import ds     from 'ember-data'
import config from 'totem-config/config'
import ns     from 'totem/ns'

class Ajax

  get_container: -> @get_instance()  # backward compatibility
  get_instance: -> @instance
  set_instance: (instance) ->
    @instance = instance
    @setup()

  setup: ->
    @adapter        = @instance.lookup('adapter:application')
    @store          = @instance.lookup('service:store')
    @totem_error    = @instance.lookup('totem:error')
    @totem_scope    = @instance.lookup('totem:scope')
    @totem_messages = @instance.lookup('totem:messages')

  array: (options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @build_query(options)
      query.success = (result) =>
        @totem_messages.api_success source: 'ajax.array', model: (options.model or options.url), action: options.action  unless options.skip_message
        resolve(result)
      query.error = (error) =>
        @totem_messages.api_failure error, source: 'ajax.array', model: (options.model or options.url), action: options.action  unless options.skip_message
        reject(error)
      @add_auth_headers(query)
      ember.$.ajax(query)

  object: (options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      query = @build_query(options)
      query.success = (result) =>
        @totem_messages.api_success source: 'ajax.object', model: (options.model or options.url), action: options.action  unless options.skip_message
        resolve(result)
      query.error = (error) =>
        @totem_messages.api_failure error, source: 'ajax.object', model: (options.model or options.url), action: options.action  unless options.skip_message
        reject(error)
      @add_auth_headers(query)
      ember.$.ajax(query)

  add_auth_headers: (query) ->
    headers = @adapter.get_auth_headers()
    query.beforeSend = (jqXHR) =>
      jqXHR.setRequestHeader('Authorization', headers.Authorization)

  adapter_model_url: (options) ->
    options.action ?= ''
    @build_query(options).url

  adapter_host: ->
    @adapter.get('host')

  build_url: (type_key, id, verb, action) ->
    url = @adapter.buildURL(type_key, id, verb)
    url += '/' + action if action
    url

  build_query: (options) ->
    verb       = options.verb or 'GET'
    action     = options.action
    model      = options.model
    id         = options.id
    data       = options.data or {}
    url        = options.url

    @error "Either [model] or [url] options must be passed.", options  unless (model or url)
    if url
      @error "[model], [action] and [id] are ignored when the url is passed; remove them.", options  if (model or action or id)
    else
      @error "Model is blank.", options   unless model
      @error "Action is blank.", options  unless action?  # allow an empty string

    query             = {}
    query.type        = verb
    query.dataType    = 'json'
    query.contentType = 'application/json; charset=utf-8'
    query.timeout     = config.ajax_timeout  if config.ajax_timeout

    # When an URL is passed, it is used 'as-is'; e.g. assumes it has any ids, actions, etc. already added.
    # Otherwise, the URL is built using the model, action and id options.
    type_key = null

    if url
      # Passing in a 'parentURL' (from urlPrefix() without params e.g. returns host/namepsace -> localhost:3000/api).
      # The parentURL is not used for absolute urls (e.g. start with '/'') or urls starting with 'http(s)'.
      # Need when running via ember-cli where the host is 'localhost:4200'.
      url = @adapter.urlPrefix(url, @adapter.urlPrefix())
    else
      switch typeof(model)
        when 'string' # string model class name.
          try
            model_class = @totem_scope.model_class_from_string(model)
            @error "Model class for [#{model}] not found.", options  unless model_class
            type_key = @totem_scope.model_class_type_key(model_class)
            @totem_scope.add_auth_to_query(model_class, data)
          catch
            type_key = model
        when 'object' # model instance.
          type_key = @totem_scope.record_type_key(model)
          @totem_scope.add_auth_to_query(model, data)
        else
          @error "Unknown model object (not a string or object).", options
          
      @error "Model typeKey is blank.", options  unless type_key
      url = @build_url(type_key, id, verb, action)

    query.data = data
    query.data = @stringify query.data unless @query_is_get(query) # GET either needs processData: false or to not be stringified.
    query.url  = url

    query

  stringify: (obj) ->
    JSON.stringify(obj)

  query_is_get: (query) -> query.type == 'GET' or query.type == 'get'

  error: (message, options=null) ->
    message ?= ''
    message += " [options: #{@stringify(options)}]"  if options
    @totem_error.throw @, "totem.ajax error: #{message}"

  toString: -> 'TotemAjax'

export default new Ajax
