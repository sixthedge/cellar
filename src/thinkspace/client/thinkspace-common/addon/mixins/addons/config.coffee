import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create

  # Addon config options:
  #   id:                     hard-set guid for component
  #   component:              hard-set to component
  #   class:                  hard-set by this service; addon should add to its highest level html tag if appropriate
  #   engine:                 [string] engine name to mount e.g. thinkspace-markup
  #   display:                [string] text to display on button (e.g. dock button) e.g. 'Comments'
  #   icon:                   [string] icon classes e.g. 'tsi tsi-left tsi-tiny tsi-comments_white'
  #   active:                 [true|false] indicates if addon active; can use to highlight button
  #   toggle_property:        [string] component property set on open/close; open to true, close to false
  #   singleton:              [true|false] if true, only this addon can be active; any other active addons will be closed
  #   init_width:             [number] pocket initial width e.g. (15% * init_width)
  #   top_pocket:             [true|false] if is a top_pocket addon
  #   right_pocket:           [true|false] if is a right_pocket addon
  #   top_pocket_singleton:   [true|false] if true, only this top_pocket addon can be active; other active top_pocket addons will be closed
  #   right_pocket_singleton: [true|false] if true, only this right_pocket addon can be active; other active right_pocket addons will be closed

  get_addon_config: (component, options={}) ->
    util.error "Addon config component must be present.", component, options if ember.isBlank(component)
    util.error "Addon config must be a hash.", component, options unless util.is_hash(options)
    util.error "Addon config must be either a top or side pocket.", component, options unless (options.right_pocket or options.top_pocket)
    addon =
      id:                     ember.guidFor(component)
      component:              component
      class:                  null
      engine:                 'no-engine'
      display:                'NONE'
      name:                   null
      icon:                   null
      active:                 false
      toggle_property:        null
      singleton:              false
      init_width:             1
      top_pocket:             false
      right_pocket:           false
      top_pocket_singleton:   false
      right_pocket_singleton: false
    ember.merge addon, options

  get_addon_config_equal_keys: (addon) ->
    ignore_keys = ['id', 'guid', 'component', 'active']
    util.hash_keys(addon).filter (key) => not ignore_keys.includes(key)

  find_open_addon_by_config: (addon) ->
    keys = @get_addon_config_equal_keys(addon)
    for active_addon in @get_active_addons()
      return active_addon if active_addon.active and util.hash_values_equal(addon, active_addon, keys)
    null
