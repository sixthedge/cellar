import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # content.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend

  builder: ember.inject.service()
  step: ember.computed.reads 'builder.step_content'

  actions:
    next_step: -> 
      opts          = {}
      opts.save     = true
      opts.validate = true if @get('step.assessment.is_balance')
      @get('builder').transition_to_next_step(opts)
    prev_step: -> 
      opts          = {}
      opts.save     = true
      opts.validate = true if @get('step.assessment.is_balance')
      @get('builder').transition_to_prev_step(opts)
      
    select:  (template) -> @get('step').select_template(template) if ember.isPresent(template)
    cancel:  -> @get('step').reset_is_editing_template()
    confirm: -> @get('step').confirm_template()
    exit: -> @get('builder').transition_to_cases_show()