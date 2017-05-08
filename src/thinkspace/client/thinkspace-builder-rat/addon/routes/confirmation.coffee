import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'
import ta    from 'totem/ds/associations'

###
# # confirmation.coffee
- Type: **Route**
- Package: **ethinkspace-builder-rat**
###
export default base.extend

  # ## Services
  # - `thinkspace-builder-rat/builder`
  builder: ember.inject.service()

  # ## Methods
  titleToken: (model) -> model.get('title')
  ## Used to call the assignment's 'load' action instead of 'show', to ensure that the assignment's phases are being rendered
  model:      (params) -> @get('builder').query_assignment(params.assignment_id)

  activate: -> 
    builder = @get('builder')
    builder.launch()
    builder.set_route(@)
    builder.set_current_step_from_id('confirmation')

  afterModel: (model) ->
    @get('builder').set_model(model)
