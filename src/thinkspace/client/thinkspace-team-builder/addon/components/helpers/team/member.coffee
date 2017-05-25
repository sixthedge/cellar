import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend
  tagName: 'li'
  classNames: ['team-panel__list-item']
  classNameBindings: ['is_highlighted:is-highlighted']

  user_id:  null
  abstract: null

  full_name: ember.computed 'model', -> return "#{@get('model.first_name')} #{@get('model.last_name')}"

  highlighted_users: []

  is_highlighted: ember.computed 'highlighted_users.@each', 'user_id', -> 
    return false if ember.isEmpty(@get('highlighted_users'))
    @get('highlighted_users').mapBy('id').contains(@get('user_id').toString())

  init_base: ->
    @init_user()

  init_user: ->
    user_id  = @get('user_id')
    abstract = @get('abstract')
    users    = abstract.users
    user     = users.findBy 'id', user_id
    @set('model', user)
