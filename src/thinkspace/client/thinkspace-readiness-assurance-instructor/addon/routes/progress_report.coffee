import ember from 'ember'
import base  from 'thinkspace-base/routes/base'

export default base.extend

  afterModel: (assignment) ->
    console.warn 'progress_report route:', assignment
    @get('thinkspace').set_current_models(assignment: assignment).then =>
      @totem_messages.hide_loading_outlet()
