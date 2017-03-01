import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  file_url: ember.computed -> @get('model.url') 