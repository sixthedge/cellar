import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  init_base: ->
    model = @get('thinkspace').get_current_assignment()
    @set 'model', model