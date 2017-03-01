import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend
  tagName: ''

  button_id:        ember.computed.reads 'choice.id'
  button_label:     ember.computed.reads 'choice.label'
  buttons_disabled: ember.computed.or 'qm.readonly', 'qm.answers_disabled'

  get_answer_id: -> @get('qm.answer_id')
  get_button_id: -> @get('button_id')

  is_selected: ember.computed 'qm.answer_id', ->
    aid = @get_answer_id()
    bid = @get_button_id()
    bid and bid == aid

  actions:
    select: ->
      return if @get('buttons_disabled')
      @sendAction 'select', @get_button_id()
