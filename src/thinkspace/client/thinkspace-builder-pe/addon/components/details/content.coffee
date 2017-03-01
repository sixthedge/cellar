import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # content.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  builder: ember.inject.service()
  step:    ember.computed.reads 'builder.current_step'

  team_sets:         ember.computed.reads 'step.team_sets'
  selected_team_set: ember.computed.reads 'step.selected_team_set'

  actions:

    select_team_set: (team_set) -> @get('step').select_team_set team_set
