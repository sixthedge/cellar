import ember from 'ember'
import base  from 'thinkspace-base/components/base'
import ns    from 'totem/ns'

export default base.extend

  edit:  false
  color: null

  selected_color: null
  colors:         null

  init_base: -> 
    @init_colors().then =>
      @init_selected_color()

  init_selected_color: ->
    colors         = @get('colors')
    color          = @get('color')
    if ember.isPresent(color)
      selected_color = colors.findBy 'color', color
    else
      selected_color = colors.get('firstObject')

    @send('select', selected_color)

  init_colors: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @tc.find_all(ns.to_p('color')).then (colors) =>
        @set('colors', colors)
        resolve(colors)

  set_color: (color) -> @set('selected_color', color)
  get_color: -> @get('selected_color')

  set_is_editing: -> @set('is_editing', true)
  reset_is_editing: -> @set('is_editing', false)

  actions:
    select: (color) -> 
      @set_color(color)
      @sendAction('select', color)
      @reset_is_editing() if @get('edit')

    edit_color: -> @set_is_editing()