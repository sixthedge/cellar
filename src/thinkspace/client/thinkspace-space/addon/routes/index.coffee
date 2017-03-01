import ember  from 'ember'
import ns     from 'totem/ns'
import base   from 'thinkspace-base/routes/base'

export default base.extend

  model: ->
    @totem_scope.ownerable_to_current_user() # ensure current user (e.g. toolbar select 'Spaces' when team ownerable)
    @tc.find_all_with_message ns.to_p('space')

  afterModel: -> @current_models().reset_models()
