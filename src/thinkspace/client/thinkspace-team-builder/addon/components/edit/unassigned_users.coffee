import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend


  actions:
    add_user: (user) ->
      @sendAction('add', user)