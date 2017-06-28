import ember       from 'ember'
import base        from 'thinkspace-base/components/base'
import qual_item   from 'thinkspace-builder-pe/items/qual'
import quant_item  from 'thinkspace-builder-pe/items/quant'

###
# # assessment.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  classNameBindings: ['readonly:is-readonly']

  value:      null
  template:   null
  manager:    ember.inject.service()
  readonly:   ember.computed.reads 'step.is_readonly'
  assessment: ember.computed.reads 'manager.assessment'

  quant_items: ember.computed.reads 'manager.quant_items'
  qual_items:  ember.computed.reads 'manager.qual_items'

  has_qual_items:  ember.computed.notEmpty 'qual_items'
  has_quant_items: ember.computed.notEmpty 'quant_items'


  actions:
    change_template: -> @get('step').set_is_editing_template()
