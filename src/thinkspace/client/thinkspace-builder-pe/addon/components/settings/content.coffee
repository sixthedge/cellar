import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # content.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  builder: ember.inject.service()

  actions:

    clicked: -> @set('clicked', true)

    select_release_at: (date) -> @get('step').select_release_at(date)
    select_due_at: (date) -> @get('step').select_due_at(date)