import ember from 'ember'
import ta from 'totem/ds/associations'

export default ember.Mixin.create
  included: ta.attr('json-api-models')
  add_included_models: (models) ->
    models   = ember.makeArray(models)
    includes = []
    models.forEach (model) => includes.pushObject(model)
    included = @get 'included'
    switch
      when ember.isNone(included)
        included = includes
      when ember.isArray(included)
        included = included.concat(includes)
      when ember.isPresent(included)
        included = ember.makeArray(included)
        included = included.concat(includes)
    @set 'included', included