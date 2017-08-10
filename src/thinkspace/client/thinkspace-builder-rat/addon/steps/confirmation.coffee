import ember from 'ember'
import step  from './step'

###
# # confirmation.coffee
- Type: **Step Object**
- Package: **thinkspace-builder-rat**
###
export default step.extend

  id: 'confirmation'
  index: 3
  route_path: 'confirmation'

  builder: ember.inject.service()
  manager: ember.inject.service()

  has_transform: ember.computed.reads 'manager.has_transform'
  assignment:    ember.computed.reads 'builder.model'

  assessments: ember.computed 'manager.irat', 'manager.trat', -> 
    arr  = ember.makeArray()
    arr.pushObject(@get('manager.irat'))
    arr.pushObject(@get('manager.trat'))
    arr