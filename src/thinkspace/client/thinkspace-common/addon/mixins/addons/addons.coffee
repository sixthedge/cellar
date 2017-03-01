import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  reset_addons: ->
    @active_addons.clear()
    @set_active_addon_ownerable(null)

  has_addon_ownerable:                    -> ember.isPresent @get_active_addon_ownerable()
  get_active_addon_ownerable:             -> @get 'active_addon_ownerable'
  set_active_addon_ownerable: (ownerable) -> @set 'active_addon_ownerable', ownerable

  clean_up_active_addons: ->
    addons = @active_addons.filter (addon) => @is_destroyed_addon(addon)
    @active_addons.removeObject(addon) for addon in addons

  get_active_addons: -> @active_addons
  has_active_addons: -> ember.isPresent(@get_active_addons())

  add_active_addon:    (addon) -> @active_addons.pushObject(addon)
  remove_active_addon: (addon) -> @active_addons.removeObject(addon)

  is_active_addon: (addon) -> addon and @get_active_addons().includes(addon)

  is_open_addon:      (addon) -> util.is_hash(addon) and addon.active == true
  is_destroyed_addon: (addon) -> util.is_hash(addon) and util.is_destroyed(addon.component)

  get_active_addon_components: -> @get_active_addons().mapBy 'component'

  toggle_addon: (addon) ->
    new ember.RSVP.Promise (resolve, reject) =>
      promise = if @is_active_addon(addon) then @close_addon(addon) else @open_addon(addon)
      ember.RSVP.Promise.all([promise]).then =>
        if @has_top_pocket_addons()   then @show_top_pocket()   else @hide_top_pocket()
        if @has_right_pocket_addons() then @show_right_pocket() else @hide_right_pocket()
        resolve()

  open_addon: (addon)   ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve() if @is_destroyed_addon(addon)
      ember.set(addon, 'active', true)
      @add_active_addon(addon)
      promises = @get_singleton_close_promises(addon)
      ember.RSVP.Promise.all(promises).then =>
        return resolve() unless @is_active_addon(addon) # ensure addon still active (e.g. was not closed via singleton)
        @increase_right_pocket(addon, addon.init_width or 1) if @is_right_pocket_addon(addon)
        @call_component(addon, 'open_addon').then =>
          @set_component_property(addon, true)
          resolve()

  get_singleton_close_promises: (addon) ->
    promises = [ember.RSVP.resolve()] # add a resolved promise in case no other promises added
    promises.push @close_all_addons(addon)              if addon.singleton == true
    promises.push @close_all_top_pocket_addons(addon)   if addon.top_pocket_singleton == true
    promises.push @close_all_right_pocket_addons(addon) if addon.right_pocket_singleton == true
    promises

  close_addon: (addon) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @remove_active_addon(addon)
      return resolve() if @is_destroyed_addon(addon)
      ember.set(addon, 'active', false)
      @decrease_right_pocket(addon, addon.width) if @is_right_pocket_addon(addon)
      @call_component(addon, 'close_addon').then =>
        @set_component_property(addon, false)
        resolve()

  close_all_addons: (addon=null) ->
    addons = if addon then @get_active_addons().without(addon) else @get_active_addons()
    @close_addons(addons)

  close_addons: (addons) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @close_addon(addon) for addon in addons
      resolve()

  call_component: (addon, fn) ->
    new ember.RSVP.Promise (resolve, reject) =>
      component = addon.component
      rc = if util.is_object_function(component, fn) then component[fn](addon) else null
      if util.is_promise(rc)
        rc.then => resolve()
      else
        resolve()

  set_component_property: (addon, tf) ->
    prop = addon.toggle_property
    comp = addon.component
    return if ember.isBlank(prop) or ember.isBlank(comp)
    comp.set(prop, tf)
