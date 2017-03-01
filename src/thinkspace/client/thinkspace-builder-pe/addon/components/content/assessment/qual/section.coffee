import ember     from 'ember'
import base      from 'thinkspace-base/components/base'

###
# # section.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  manager: ember.inject.service()

  actions: 
    create: -> @get('manager').add_qual_item()