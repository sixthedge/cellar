import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  layout: ember.computed -> @get('tvo').template.compile()
