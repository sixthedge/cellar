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

  builder:    ember.inject.service()
  manager:    ember.inject.service()

  assignment:    ember.computed.reads 'builder.model'
  assessment:    ember.computed.reads 'manager.model'
  
  has_transform: ember.computed.reads 'assessment.has_transform'