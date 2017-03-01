import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend
  # ### Properties
  title:       ta.attr('string')
  path:        ta.attr('string')
  img_src:     ta.attr('string')
  description: ta.attr('string')

  is_pe:  ember.computed.equal 'title', 'Peer Evaluation'
  is_rat: ember.computed.equal 'title', 'Readiness Assurance'

  # ### Computed properties
  r_step_details: ember.computed 'path', -> @get_path_for_step('details')

  # ### Helpers
  get_path_for_step: (step) -> @get('path') + ".#{step}"