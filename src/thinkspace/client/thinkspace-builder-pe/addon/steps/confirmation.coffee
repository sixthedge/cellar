import ember from 'ember'
import step  from './step'

###
# # confirmation.coffee
- Type: **Step Object**
- Package: **ethinkspace-builder-pe**
###
export default step.extend

  id: 'confirmation'
  index: 3
  route_path: 'confirmation'

  builder: ember.inject.service()