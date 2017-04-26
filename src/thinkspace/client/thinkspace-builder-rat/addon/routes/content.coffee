import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

###
# # content.coffee
- Type: **Route**
- Package: **ethinkspace-builder-rat**
###
export default base.extend

  # ## Services
  # - `thinkspace-builder-rat/builder`
  builder: ember.inject.service()

  # ## Methods
  titleToken: (model) -> model.get('title')
  model:      (params) -> @tc.find_record(ns.to_p('assignment'), params.assignment_id)

  activate: -> 
    builder = @get('builder')
    builder.launch()
    builder.set_route(@)
    builder.set_current_step_from_id('content')

  afterModel: (model) ->
    @get('builder').set_model(model)