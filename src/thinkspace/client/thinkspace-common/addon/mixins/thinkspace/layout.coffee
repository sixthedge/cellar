import ember  from 'ember'
import config from 'totem-config/config'

export default ember.Mixin.create

  sticky_browser_resize: null

  set_component_column_as_sticky: (component) ->
    columns_class = ".#{config.grid.classes.columns}"
    sticky_class  = config.grid.classes.sticky
    $column       = component.$().parents(columns_class).first()
    return unless ember.isPresent($column)
    $column.addClass(sticky_class)
    $siblings = $column.siblings(columns_class)
    $siblings.addClass(sticky_class)
    @bind_sticky_columns()

  bind_sticky_columns: ->
    @add_height_to_sticky_columns()
    @bind_sticky_browser_resize()

  add_height_to_sticky_columns: ->
    sticky_class = ".#{config.grid.classes.sticky}"
    height       = @get_visible_content_height()
    $(sticky_class).each (i, container) =>
      $container = $(container)
      $container.css 'height', "#{height}px"

  get_visible_content_height: ->
    h_window = $(window).height()
    h_nav    = $('#navbar').outerHeight()
    h_dock   = $('.thinkspace-dock').outerHeight()
    h_window - h_nav - h_dock

  bind_sticky_browser_resize: ->
    return if ember.isPresent(@get('sticky_browser_resize'))
    binding = $(window).resize =>
      @add_height_to_sticky_columns()
    @set 'sticky_browser_resize', binding

  # ### Notifications and sockets
  add_system_notification: (type, message, sticky=true) ->
    fn = totem_messages[type]
    totem_messages[type](message, sticky) if fn?
