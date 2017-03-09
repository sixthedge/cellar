import ember from 'ember'
import base  from 'thinkspace-base/services/base'
import totem_messages from 'totem-messages/messages'

export default base.extend

  current_space: null

  set_current_space: (space) -> 
    console.log('space is ', space)
    @set('current_space', space) if ember.isPresent(space)