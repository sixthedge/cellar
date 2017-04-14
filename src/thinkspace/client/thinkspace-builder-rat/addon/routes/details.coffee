import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

###
# # confirmation.coffee
- Type: **Route**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  # ## Services
  # - `thinkspace-builder-pe/builder`
  builder: ember.inject.service()

  # ## Methods
  titleToken: (model) -> model.get('title')
  model:      (params) -> @tc.find_record(ns.to_p('assignment'), params.assignment_id)

  activate: -> 
    builder = @get('builder')
    builder.launch()
    builder.set_route(@)
    builder.set_current_step_from_id('details')

  afterModel: (model) ->
    @get('builder').set_model(model)
