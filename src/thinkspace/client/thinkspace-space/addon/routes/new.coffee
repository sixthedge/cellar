import ember  from 'ember'
import ns     from 'totem/ns'
import base   from 'thinkspace-base/routes/base'

export default base.extend

  model: -> 
    @set 'space', @totem_scope.get_store().createRecord ns.to_p('space')
    @get('space')

  deactivate: ->
    @get('space').deleteRecord() if (@get('space.isNew') && !@get('space.isSaving'))

