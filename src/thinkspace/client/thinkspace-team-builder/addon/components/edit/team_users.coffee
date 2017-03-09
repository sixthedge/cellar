import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  actions:
    remove_user: (user) ->
      @sendAction('remove', user)