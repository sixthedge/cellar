import ember from 'ember'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  init_base: ->
    collection       = @get('collection')
    model            = ember.makeArray()
    display_property = @get('display_property')
    select_action    = @get('select_action')

    collection.forEach (member, index) =>
      item = {}
      item.id = index
      item.model = if member.hasOwnProperty('model') then member.model else member
      item.display_property = if member.hasOwnProperty('display_property') then member.display_property else display_property
      item.select_action = if member.hasOwnProperty('select_action') then member.select_action else select_action

      @set "select_action_#{item.id}", item.select_action
      model.pushObject item

    @set 'model', model

  get_select_action_for_item: (item) -> "select_action_#{item.id}"

  actions:

    select: (item) ->
      console.log "item.select_action", item, item.select_action
      @set 'selected_item', item.model
      @sendAction @get_select_action_for_item(item), item.model



  # toggle_action:     null
  # checked:           false
  # disabled:          false
  # label:             null
  # disable_click:     false
  # class:             null
  # classNameBindings: ['checked:is-checked', 'class']
  # classNames:        ['ts-radio_button']

  # click: -> @toggle_checked() unless @get('disable_click')

  # toggle_checked: ->
  #   @toggleProperty 'checked'
  #   @sendAction('toggle_action', @get('checked')) if @get('toggle_action')