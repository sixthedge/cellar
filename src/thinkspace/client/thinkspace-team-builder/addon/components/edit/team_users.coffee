import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  sorted_users: null
  first_order: 'asc'
  last_order:  'asc'


  init_base: ->
    @init_sorted_users()

  init_sorted_users: ->
    users = @get('model')



  actions:
    remove_user: (user) ->
      @sendAction('remove', user)