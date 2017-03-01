import tm from 'totem-messages/messages'

initializer =
  name: 'totem-messages'
  initialize: (instance) ->

    tm.set_container(instance)

export default initializer
