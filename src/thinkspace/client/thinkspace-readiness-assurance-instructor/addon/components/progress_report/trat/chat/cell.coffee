import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'totem-table/components/table/cell'

export default base.extend
  # # Properties
  ownerable: null

  # # Computed properties
  team:          ember.computed.reads 'row'
  chat_messages: ember.computed.reads 'cm.messages'

  # # Events
  init_base: ->
    rms         = @get('column.data.rms')
    question_id = @get('column.data.question_id')
    team_id     = @get('row.id')
    @rm = rms.find (rm) =>
      rm.is_for_ownerable(team_id, 'thinkspace/team/team')
    @qm = @rm.question_manager_map.get(question_id)
    @cm = @rm.chat_manager_map.get(question_id)
    @rm.get_response_ownerable().then (ownerable) =>
      @set('ownerable', ownerable)
    
