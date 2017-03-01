import ember from 'ember'

queue = ember.Object.extend()

queue.reopenClass

  base_name: 'totem_data'

  requests_queue: ember.Map.create()

  get_requests_queue: -> @requests_queue

  queue_request: (source, name, id) ->
    queue     = @get_requests_queue()
    req_id    = @get_request_id(name, id)
    req_queue = queue.get(req_id)
    if req_queue and ember.isArray(req_queue)
      req_queue.push(source)
      true
    else
      queue.set req_id, []
      false

  delete_queue_request: (name, id) ->
    queue     = @get_requests_queue()
    req_id    = @get_request_id(name, id)
    req_queue = queue.get(req_id)
    if ember.isPresent(req_queue) and ember.isArray(req_queue)
      for source in req_queue
        if source.get("#{@base_name}_include.#{name}") == true
          source["#{@base_name}_#{name}"].refresh()
    queue.delete(req_id)

  get_request_id: (name, id) -> name + '--' + id

  get_totem_data_properties: (source) -> source.get_totem_data_properties() or []

  debug_queue: (title='') ->
    console.log title  if title
    @get_requests_queue().forEach (value, key) ->
      console.info "  key   = ", key
      console.info "  value = ", value
      console.info ' '

  toString: -> "#{@base_name.camelize()}Queue"

export default queue
