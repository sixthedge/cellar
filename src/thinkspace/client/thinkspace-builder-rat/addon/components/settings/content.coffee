import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # content.coffee
- Type: **Component**
- Package: **thinkspace-builder-rat**
###
export default base.extend

  builder: ember.inject.service()

  actions:
    select_release_at: (date) -> @get('step').select_release_at(date)
    select_due_at: (date) -> @get('step').select_due_at(date)