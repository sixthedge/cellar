import ember from 'ember'

export default ember.Mixin.create
  tagName: ''

  addon: null

  # TODO: Determine how to mount engine but not in a pocket (e.g. tvo.value setting?)

  init: ->
    @_super(arguments...)
    @addons = @get('addons')
    if @get('can_access_addon')
      @add_dock_addon()
      @init_dock()
      @reopen_destroyed_dock()

  reopen_destroyed_dock: ->
    return unless @addons.is_dock_addon_open_and_destroyed(@addon)
    @addons.clean_up_active_addons()
    @addons.clean_up_dock_addons()
    @addons.toggle_addon(@addon)

  _add_dock_addon_observer: ember.observer 'can_access_addon', -> if @get('can_access_addon') then @add_dock_addon() else @remove_dock_addon()

  add_dock_addon: ->
    addon = @get('addon')
    if ember.isBlank(addon)
      addon_config = @get('addon_config')
      addon        = @addons.get_addon_config(@, addon_config)
      @set 'addon', addon
    @addons.add_dock_addon(addon) unless @addons.is_dock_addon(addon)

  remove_dock_addon: ->
    addon = @get('addon')
    @addons.remove_dock_addon(addon)

  close_dock_addon: ->
    addon = @get('addon')
    return if ember.isBlank(addon)
    @addons.close_addon(addon) if @addons.is_active_addon(addon)
    @addons.remove_dock_addon(addon)

  # ###
  # ### Component should override the following:
  # ###
  addon_config:     {}          # addon configuration hash (see 'addons' service for options)
  can_access_addon: false       # if addon can be used on current route (typically a computed property)
  init_dock:        -> return   # function to called after dock mixin init; only called if 'can_access_addon'
  open_addon:       -> return   # function to open the addon;  e.g. init setup; can be a promise; set show=true  (unless addon_config has toggle_property)
  close_addon:      -> return   # function to close the addon; e.g. do cleanup; can be a promise; set show=false (unless addon_config has toggle_property)
