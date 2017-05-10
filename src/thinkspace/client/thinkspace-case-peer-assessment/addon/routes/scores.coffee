import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

###
# # scores.coffee
- Type: **Route**
- Package: **thinkspace-peer-assessment**
###
export default base.extend
  titleToken: (model) -> model.get('title')

  afterModel: (assignment, transition) ->
    transition.abort()  unless assignment
    @current_models().set_current_models(assignment: assignment)