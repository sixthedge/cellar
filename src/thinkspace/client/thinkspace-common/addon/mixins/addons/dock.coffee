import ember from 'ember'

export default ember.Mixin.create

  dock_is_visible: true

  reset_dock: ->
    @dock_addons.clear()
    @reset_top_pocket()
    @reset_right_pocket()
    @show_dock()

  clean_up_dock_addons: ->
    addons = @dock_addons.filter (addon) => @is_destroyed_addon(addon)
    @dock_addons.removeObject(addon) for addon in addons

  add_dock_addon:    (addon) -> addon and @dock_addons.pushObject(addon)
  remove_dock_addon: (addon) -> addon and @dock_addons.removeObject(addon)

  is_dock_addon: (addon) -> addon and @dock_addons.includes(addon)

  hide_dock: -> @set_dock_is_visible(false)
  show_dock: -> @set_dock_is_visible(true)

  set_dock_is_visible: (tf) -> @set 'dock_is_visible', tf

  open_dock_right_pocket_addon_by_name: (name) ->
    new ember.RSVP.Promise (resolve, reject) =>
      addon = @find_dock_addon_by_name(name)
      return resolve(null)  if ember.isBlank(addon)
      return resolve(addon) if addon.active == true
      @open_addon(addon).then =>
        @show_right_pocket()
        resolve(addon)

  find_dock_addon_by_name: (name) ->
    return null if ember.isBlank(name)
    @dock_addons.findBy 'name', name

  is_dock_addon_open_and_destroyed: (dock_addon) ->
    addon = @find_open_addon_by_config(dock_addon)
    ember.isPresent(addon) and @is_destroyed_addon(addon) and @is_open_addon(addon)
