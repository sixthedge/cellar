import ember from 'ember'
import ta    from 'totem/ds/associations'
import ns    from 'totem/ns'

export default ta.Model.extend ta.add(
    ta.polymorphic 'authable'
    ta.polymorphic 'ownerable'
    ta.polymorphic 'creatorable'
    ta.polymorphic 'discussionable'
    ta.has_many    'comments'
  ),

  user_id:             ta.attr('number')
  authable_id:         ta.attr('number')
  authable_type:       ta.attr('string')
  ownerable_id:        ta.attr('number')
  ownerable_type:      ta.attr('string')
  creatorable_id:      ta.attr('number')
  creatorable_type:    ta.attr('string')
  discussionable_id:   ta.attr('number')
  discussionable_type: ta.attr('string')
  value:               ta.attr()
  updated_at:          ta.attr('date')
  created_at:          ta.attr('date')
  updateable:          ta.attr('boolean')

  # ### Properties
  page_height: 1500.0

  # ### Computed properties
  # TODO: This really only supports the default marker.
  sort_by: ember.computed 'value', ->
    y_pos       = @get 'value.position.y'
    page        = @get 'value.position.page'
    page_height = @get 'page_height'
    parseFloat(y_pos) + (parseFloat(page) * parseFloat(page_height))

  # ### Helpers
  get_commenterables: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get(ns.to_p('comments')).then (comments) =>
        commenterable_promises = comments.getEach('commenterable')
        ember.RSVP.Promise.all(commenterable_promises).then (commenterables) =>
          resolve commenterables