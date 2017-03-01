import ember from 'ember'

export default ember.Mixin.create

  message_item: ember.Object.extend

    is_new:      ember.computed.equal 'state', 'new'
    pre_message: ember.computed -> @tms.format_pre(@)

    set_new:     -> @set 'state', 'new'
    set_prevous: -> @set 'state', 'previous'

    toString: -> 'TotemMessageQueueItem'
