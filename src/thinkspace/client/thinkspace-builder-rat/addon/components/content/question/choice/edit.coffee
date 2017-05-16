import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # choice/edit.coffee
- Type: **Component**
- Package: **ethinkspace-builder-rat**
###
export default base.extend
  ## Model is ember object wrapping raw choice json
  manager: ember.inject.service()
  model:   null

  prefix:     ember.computed.reads 'model.prefix'
  is_answer:  ember.computed.reads 'model.is_answer'
  cur_answer: null

  is_correct: ember.computed 'is_answer', 'cur_answer', ->
    cur_answer = @get('cur_answer')
    if @get('model.id') == cur_answer
      return true
    else
      if ember.isEmpty(cur_answer)
        return @get('is_answer')
      else
        return false

  actions:
    delete:        -> @sendAction('delete', @get('model.model'))
    select_answer: -> 
      @sendAction('select_answer', @get('model'))