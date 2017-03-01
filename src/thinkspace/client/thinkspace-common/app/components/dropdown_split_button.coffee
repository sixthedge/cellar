import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'
#
# dropdown_split_button (see usage at bottom of this file)
#
export default base.extend
  # ### Properties
  classNames: ['thinkspace-dropdown']

  first_button:     null
  buttons:          null
  dropdown_text:    ''
  list_width_class: null
  icon_classes:     'tsi icon-small tsi-down-caret-inverse'

  # ### Computed properties
  drop_id: ember.computed -> "ts-drop_#{@get('elementId')}"

  # ### Observers
  collection_observer: ember.observer 'collection', ->
    # Run next, otherwise the dropdown will never dissapear on click if the item changes.
    ember.run.next =>
      @map_buttons() unless @get('isDestroying') or @get('isDestroyed')

  # ### Events
  init_base: ->
    @map_buttons()

  # didInsertElement: -> $(document).foundation()
  # didInsertElement: -> @$('ul').foundation()
  # didInsertElement: ->
  #   ember.run.schedule 'afterRender', =>
  #     $ul = @$('ul')
  #     @dd = new Foundation.Dropdown($ul)
  didInsertElement: ->
    $ul = @$('ul')
    @dd = new Foundation.Dropdown($ul)

  # ### Helpers
  map_buttons: ->
    collection = (@get('collection') or []).concat([])
    collection.map (params) => @set(params.action, params.action) if params.action  # set the actions for sendAction
    @set_list_width_class(collection)
    @set 'first_button', collection.shift()  if @get('show_button') != false
    @set 'dropdown_text', @get('text') or ''
    @set 'buttons', collection

  set_list_width_class: (collection) ->
    lengths = collection.map (hash) -> (hash.display and hash.display.length) or 0
    max     = lengths.sort().pop() or 0
    switch
      when max < 15 then  klass = 'thinkspace-dropdown_split-button-small'
      when max < 25 then  klass = 'thinkspace-dropdown_split-button-medium'
      else                klass = 'thinkspace-dropdown_split-button-large'
    @set 'list_width_class', klass

  actions:
    _select: (params) ->
      action = params.action
      @set action, action
      @sendAction params.action, params
      @dd.close()

# A simplified version of the dropdown component (e.g. less features).
# Assumes an ordered array of configuration objects containing a main button
# followed by dropdown options (when only one configuration object, no dropdown is shown).
#
# Required in each configuration params:
#   display: [string] Text to display
#
# Optional configuration params:
#
#   action:       [string] an action in the calling component e.g. called via sendAction
#   route:        [string] link-to route when button/dropdown selected
#   model:        [model]  model to include in the link-to route (only one model is supported)
#   button_class: [string] css class(s) applied to the main button and dropdown button.
#   text:         [string] default '', if show_button == false, add text before caret.
#   show_button:  [true|false] default true, suppress showing the first config button but show caret and include in dropdown.
#
# Route option:
#   Add a 'link-to route'.  If model is also present, 'link-to route model'.
#   IMPORTANT: When using a route with a model, the 'dropdown_collection' property must be a computed property.
#              Also required if 'get' a route property e.g. @get('r_space_show')
#
#   Example:
#    Component:
#      dropdown_collection: ember.computed -> [
#        {display: 'Clone Me', route: @get('r_clone_me'), model: @get('model')}
#      ]
#      r_clone_me: ns.to_r 'space', 'clone'
#    Template:
#      component c_dropdown_split_button collection=dropdown_collection button_class='btn-small btn-default'
#
# Action option:
#   The configuration params are passed back to the calling component's action (sendAction params.action, params).
#   The calling component can use or ignore them.
#
#   Example:
#    Calling template:
#      component c_dropdown_split_button collection=dropdown_collection button_class='btn-small btn-default'
#    Calling component:
#       dropdown_collection: [
#        {display: 'Clone Me',  action: 'clone', some_value: '123'}
#        {display: 'Delete', action: 'delete'}
#      ]
#       actions:
#        clone: (params) -> do something
#        delete: -> do something (ignore params since not needed)
#   Example: suppress button and show text (main button text becomes first item in dropdown list)
#     component c_dropdown_split_button collection=dropdown_collection button_class='btn-small btn-default' show_button=false text='Select me'
#
