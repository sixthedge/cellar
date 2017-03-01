import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # quant.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  model: null
  index: null

  display_index: ember.computed 'index', -> @get('index') + 1

  label:      ember.computed.reads 'model.label'
  settings:   ember.computed.reads 'model.settings'
  id:         ember.computed.reads 'model.id'

  min_points: ember.computed.reads 'settings.points.min'
  max_points: ember.computed.reads 'settings.points.max'

  min_label:  ember.computed.reads 'settings.labels.scale.min'
  max_label:  ember.computed.reads 'settings.labels.scale.max'
