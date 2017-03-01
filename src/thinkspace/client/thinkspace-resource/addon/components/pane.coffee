import ember from 'ember'
import base  from 'thinkspace-base/components/base'

export default base.extend

  manage_files_expanded: false
  manage_links_expanded: false
  manage_tags_expanded:  false

  right_pocket_increased: false

  actions:

    toggle_files_pane: ->
      if @toggleProperty('manage_files_expanded')
        @close_links_pane()
        @close_tags_pane()

    toggle_links_pane: ->
      if @toggleProperty('manage_links_expanded')
        @close_files_pane()
        @close_tags_pane()
        @increase_right_pocket()
      else
        @decrease_right_pocket()

    toggle_tags_pane: ->
      if @toggleProperty('manage_tags_expanded')
        @close_files_pane()
        @close_links_pane()
        @increase_right_pocket()
      else
        @decrease_right_pocket()

  close_files_pane: -> @set('manage_files_expanded', false)
  close_links_pane: -> @set('manage_links_expanded', false)
  close_tags_pane:  -> @set('manage_tags_expanded',  false)

  increase_right_pocket: ->
    return if @get('right_pocket_increased')
    addons = @get('addons')
    addons.increase_right_pocket(@addon)
    @set 'right_pocket_increased', true

  decrease_right_pocket: ->
    return unless @get('right_pocket_increased')
    addons = @get('addons')
    addons.decrease_right_pocket(@addon)
    @set 'right_pocket_increased', false
