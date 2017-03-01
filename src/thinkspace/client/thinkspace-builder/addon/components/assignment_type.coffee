import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  model:  null # assignment_type
  create: null

  actions: 
    create: -> @sendAction('create', @get('model'))