import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/routes/base'

###
# # application.coffee
- Type: **Route**
- Package: **thinkspace-peer-assessment**
###
export default base.extend
  model: (params) -> @tc.find_record_with_message ns.to_p('assignment'), params.assignment_id
