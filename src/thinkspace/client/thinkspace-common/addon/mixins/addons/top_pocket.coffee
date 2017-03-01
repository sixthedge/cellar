import ember from 'ember'

export default ember.Mixin.create

  top_pocket_is_expanded: false

  reset_top_pocket: -> @hide_top_pocket()

  show_top_pocket: -> @set 'top_pocket_is_expanded', true
  hide_top_pocket: -> @set 'top_pocket_is_expanded', false

  get_top_pocket_addons: -> @get_active_addons().filterBy 'top_pocket', true
  has_top_pocket_addons: -> ember.isPresent @get_top_pocket_addons()

  is_top_pocket_addon: (addon) -> addon and addon.top_pocket == true

  close_all_top_pocket_addons: (addon=null) ->
    addons = if addon then @get_top_pocket_addons().without(addon) else @get_top_pocket_addons()
    @close_addons(addons)
