import ember from 'ember'

export default ember.Mixin.create

  init: ->
    @_super(arguments...)
    @active_addons          = []
    @active_addon_ownerable = null
    @dock_addons            = []

