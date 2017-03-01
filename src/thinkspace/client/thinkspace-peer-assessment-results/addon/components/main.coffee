import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  init_base: ->
    model = @get('thinkspace').get_current_assignment()
    @set 'model', model