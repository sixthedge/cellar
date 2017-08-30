import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend

  init_base: ->
    @set('current_user', @totem_scope.get_current_user())
