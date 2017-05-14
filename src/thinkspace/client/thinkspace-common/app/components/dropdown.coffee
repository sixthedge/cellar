import ember from 'ember'
import base  from 'thinkspace-base/components/base'

## thinkspace-dropdown
#
## options:
# collection: list of records or strings or objects to display
#   => if records, need to provide a display_property
#   => if objects, should take the form of [{display: 'stuff', route: 'posts/new', , route_param_key: 'id', action: 'link_selected'}]
#
# select_action: if set, will send action to the action_receiver with the selected item
# action_receiver: context to receive the select_action. only needed if select_action is specified
#
# select_route: if set, will link-to the specified route using the item as a param
# text: base text to display on the anchor tag i.e. 'select a student'
# selected: the currently selected object.
#
## you may also pass the following properties to add custom classes to elements in string form, i.e. "class-a class-b class-c"
#   class
#   anchor_class
#   list_class
#   list_item_class
#   link_class

export default base.extend
  classNames: ['otbl-dropdown']

  default_anchor_class:    'dropdown__anchor'
  default_list_class:      'f-dropdown dropdown__list'
  default_list_item_class: 'dropdown__item'
  default_link_class:      'dropdown__item-link'

  anchor_classes:    ember.computed 'anchor_class',     -> @concat_class('anchor')
  list_classes:      ember.computed 'list_class',       -> @concat_class('list')
  list_item_classes: ember.computed 'list_item_class',  -> @concat_class('list_item')
  link_classes:      ember.computed 'link_class',       -> @concat_class('link')

  drop_id: ember.computed -> "ts-drop_#{@get('elementId')}"

  concat_class: (tag) ->
    default_class = @get("default_#{tag}_class")
    custom_class  = @get("#{tag}_class")
    if custom_class then return default_class.concat(' ', custom_class) else return default_class

  # ### Keyboard support
  keyDown: (event) ->
    key_code = event.keyCode
    switch key_code
      when 38 # up arrow
        @select_previous()
        event.stopPropagation()
        event.preventDefault()
      when 40 # down arrow
        @select_next()
        event.stopPropagation()
        event.preventDefault()

  select_next: -> @select_from_offset(1)

  select_previous: -> @select_from_offset(-1)

  select_from_offset: (offset) ->
    collection      = @get 'collection'
    selected        = @get 'selected'
    index           = collection.indexOf(selected)
    find_at         = index + offset
    return if index == -1 # Not found
    if collection.length > find_at and find_at >= 0
      object = collection.objectAt(find_at)
      @set 'selected', object
      @set_selected_text()

  set_selected_text: ->
    selected         = @get 'selected'
    display_property = @get 'display_property'
    return unless ember.isPresent(selected) and ember.isPresent(display_property)
    if selected[display_property]? then text = selected[display_property] else text = selected.get(display_property)
    @set 'text', text

  send_selection_event: ->
    selected        = @get 'selected'
    select_action   = @get 'select_action'
    action_receiver = @get 'action_receiver'
    return unless ember.isPresent(select_action) and ember.isPresent(action_receiver)
    action_receiver.send(select_action, selected)

  # ### Callbacks
  auto_width: false

  callback_auto_width: ->
    drop_selector = '#' + @get('drop_id')
    $drop         = @$(drop_selector)
    klass         = ''
    $drop.children('li').each (i, child) =>
      $child     = $(child)
      text       = $child.text()
      characters = text.length
      switch
        when characters < 5, characters >= 0
          klass = 'thinkspace-dropdown_small'
        when characters < 10, characters >= 5
          klass = 'thinkspace-dropdown_medium'
        else
          klass = 'thinkspace-dropdown_large'

    $drop.addClass klass

  actions:
    click_callbacks: ->
      @callback_auto_width() if @get('auto_width')

    select: ->
      @get('dropdown').close()

  init_base: ->
    ember.run.schedule 'afterRender', =>
      $dd = @$('.dropdown-pane')
      dropdown = new Foundation.Dropdown($dd)
      @set 'dropdown', dropdown
