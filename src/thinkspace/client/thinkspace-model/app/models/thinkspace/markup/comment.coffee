import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'commenterable'
    ta.has_many    'comments',
      inverse: ta.to_p('comment:parent')
      reads: {}
    ta.belongs_to  'comment:parent',
      type:    ta.to_p('comment')
      inverse: ta.to_p('comments')
    ta.belongs_to 'discussion'
  ),

  comment:            ta.attr('string')
  commenterable_id:   ta.attr('number') # Who commented? [user|team]
  commenterable_type: ta.attr('string')
  user_id:            ta.attr('number')
  updated_at:         ta.attr('date')
  created_at:         ta.attr('date')
  updateable:         ta.attr('boolean')
  parent_id:          ta.attr('number')
  discussion_id:      ta.attr('number')
  position:           ta.attr('number')

  can_update: ember.computed 'id', 'updateable', -> return if ember.isPresent(@get('id')) then @get('updateable') else true

  has_no_comment: ember.computed.empty 'comment'
  is_child:       ember.computed.notEmpty 'parent_id'
  has_children:   ember.computed.notEmpty 'comments'
