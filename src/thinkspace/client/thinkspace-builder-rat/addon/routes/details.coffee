import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

###
# # details.coffee
- Type: **Route**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  # ## Services

  # ## Methods
  titleToken: (model) -> model.get('title')

  model:      (params) -> @tc.find_record(ns.to_p('assignment'), params.assignment_id)