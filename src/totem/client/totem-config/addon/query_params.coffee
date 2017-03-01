import ember from 'ember'
import util  from 'totem/util'
import ns    from 'totem/ns'
import tc    from 'totem-config/configs'
import fm    from 'totem-config/find_modules'

class TotemQueryParams

  constructor: -> @map = {}

  process: (instance) ->
    qp_params = tc.get_query_params()
    return if ember.isBlank(qp_params)
    for qp_array in qp_params
      @error "Query params is not an array.", qp_array  unless util.is_array(qp_array)
      @process_query_params(qp) for qp in qp_array
    @add_query_params_properties_to_model_classes(instance)

  process_query_params: (qp) ->
    @error "Query params is not a hash.", qp unless util.is_hash(qp)
    model = qp.model
    args  = qp.args
    @error "Query params model path is not a string.", qp            unless util.is_string(model)
    @error "Query params args is not a hash.", qp                    unless util.is_hash(args)
    @error "Query params model path '#{model}' is a duplicate.", qp  if ember.isPresent(@map[model])
    @map[model] = args

  add_query_params_properties_to_model_classes: (instance) ->
    for model, args of @map
      path = ns.to_p(model)
      @error "Query params model path '#{model_path}' does not exist."  if ember.isBlank(path)
      model_class = fm.factory(instance, 'model', path)
      @error "Query params model class '#{model_path}' for path '#{path}' does not exist."  if ember.isBlank(model_class)
      model_class.reopenClass
        include_authable_in_query:  args.authable  or false
        include_ownerable_in_query: args.ownerable or false

  error: -> util.error(@, arguments...)

  toString: -> 'TotemQueryParams'

export default new TotemQueryParams
