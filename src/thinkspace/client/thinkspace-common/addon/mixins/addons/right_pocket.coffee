import ember from 'ember'

export default ember.Mixin.create

  right_pocket_width_class: ember.computed 'right_pocket_is_expanded', 'right_pocket_width', ->
    return null unless @get 'right_pocket_is_expanded'
    "right-pocket_width-#{@get_right_pocket_width()}"

  right_pocket_is_expanded: false
  right_pocket_width:       0

  reset_right_pocket: -> @reset_right_pocket_width()

  show_right_pocket: -> @set 'right_pocket_is_expanded', true
  hide_right_pocket: -> @setProperties(right_pocket_is_expanded: false, right_pocket_width: 0)

  get_right_pocket_width:         -> @get 'right_pocket_width'
  set_right_pocket_width: (width) -> @set 'right_pocket_width', width
  reset_right_pocket_width:       -> @set_right_pocket_width(0)

  get_right_pocket_addons: -> @get_active_addons().filterBy 'right_pocket', true
  has_right_pocket_addons: -> ember.isPresent @get_right_pocket_addons()

  is_right_pocket_addon: (addon) -> addon and addon.right_pocket == true

  close_all_right_pocket_addons: (addon=null) ->
    addons = if addon then @get_right_pocket_addons().without(addon) else @get_right_pocket_addons()
    @close_addons(addons)

  increase_right_pocket: (addon, width=1) ->
    width             = 1 unless width
    right_pocket_width  = @get_right_pocket_width()
    right_pocket_width += width
    addon.width       = (addon.width or 0) + width
    @set_right_pocket_width(right_pocket_width)
    @set_addon_right_pocket_class()

  decrease_right_pocket: (addon, width=1) ->
    width             = 1 unless width
    right_pocket_width  = @get_right_pocket_width()
    right_pocket_width -= width
    addon.width       = (addon.width or 1) - width
    addon.width       = 0 if addon.width < 1
    @set_right_pocket_width(right_pocket_width)
    @set_addon_right_pocket_class()

  set_addon_right_pocket_class: ->
    addons = @get_right_pocket_addons()
    return if ember.isBlank(addons)
    all_addons_width = 0
    addons.map (addon) => all_addons_width += addon.width
    each_width = Math.floor(12 / all_addons_width) or 1
    extra      = 12 - (each_width * all_addons_width)
    extra      = 0 if extra < 1
    for addon in addons
      width = addon.width or 1
      cols  = each_width * width
      if extra > 0 and width > 1
        cols  += 1
        extra -= 1
      cols_class = "right-pocket_addon small-#{cols} ts-grid_columns"
      ember.set addon, 'class', cols_class
