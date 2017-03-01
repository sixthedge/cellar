import ember from 'ember'
import util  from 'totem/util'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.polymorphic 'reviewable'
    ta.belongs_to  'tbl:review_set', reads: { }
  ),

  value:           ta.attr()
  reviewable_type: ta.attr('string')
  reviewable_id:   ta.attr('number')
  assessment_id:   ta.attr('number')
  state:           ta.attr('string')
  value_is_dirty:  false

  is_approved:       ember.computed.equal 'state', 'approved'
  is_sent:           ember.computed.equal 'state', 'sent'
  is_submitted:      ember.computed.equal 'state', 'submitted'
  is_not_approved:   ember.computed.not   'is_approved'
  is_not_sent:       ember.computed.not   'is_sent'
  is_approvable:     ember.computed.and   'is_not_approved', 'is_not_sent'
  is_not_approvable: ember.computed.not   'is_approvable'
  is_unapprovable:   ember.computed.or    'is_approved', 'is_submitted'

  quantitative_path: 'value.quantitative'
  qualitative_path:  'value.qualitative'
  positive_type:     'positive'
  constructive_type: 'constructive'

  positive_comments:     ember.computed 'value', -> @get_positive_qualitative_comments()
  constructive_comments: ember.computed 'value', -> @get_constructive_qualitative_comments()

  reset_value_is_dirty: -> @set 'value_is_dirty', false
  set_value_is_dirty:   -> @set 'value_is_dirty', true

  set_quantitative_value:          (id, value) -> util.set_path_value(@, "#{@get('quantitative_path')}.#{id}.value", value)
  set_quantitative_comment:        (id, value) -> util.set_path_value(@, "#{@get('quantitative_path')}.#{id}.comment.value", value)
  get_quantitative_value_for_id:   (id) -> @get("#{@get('quantitative_path')}.#{id}.value")
  get_quantitative_comment_for_id: (id) -> @get("#{@get('quantitative_path')}.#{id}.comment.value")
  
  set_qualitative_value:           (id, type, value) -> 
    util.set_path_value(@, "#{@get('qualitative_path')}.#{id}.value", value)
    util.set_path_value(@, "#{@get('qualitative_path')}.#{id}.feedback_type", type)
  get_qualitative_value_for_id:    (id) -> @get("#{@get('qualitative_path')}.#{id}.value")
  get_expended_points: ->
    items  = @get( @get('quantitative_path') )
    points = 0
    for id of items
      points += items[id].value
    points
  get_positive_qualitative_comments:     ->  @get_qualitative_comments_for_type  @get('positive_type')
  get_constructive_qualitative_comments: ->  @get_qualitative_comments_for_type  @get('constructive_type')
  get_qualitative_comments_for_type:     (type) ->
    comments         = @get_qualitative_comments()
    comments_of_type = []
    return [] unless ember.isPresent(comments)
    for id of comments
      if comments[id].feedback_type == type
        comments_of_type.pushObject comments[id]
    comments_of_type

  get_qualitative_comments: -> 
    comments = @get( @get('qualitative_path') )
    for id of comments
      comments[id].id = id # Add the ID to the record for easier usage.
    comments

  get_qualitative_items: -> @get( @get('qualitative_path') )
  get_qualitative_comment_for_id: (id) -> @get("#{@get('qualitative_path')}.#{id}")

  valid_qualitative_items_count: ->
    items = @get( @get('qualitative_path') )
    return 0 unless ember.isPresent(items)
    valid = 0
    for id of items
      valid += 1 if ember.isPresent(items[id].value)
    valid