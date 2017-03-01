import ember from 'ember'
import base  from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend

  init_base: ->
    rooms = @rooms || @se.get_admin_room()
    @se.set_filter_rooms(rooms)
    @set_ready_on()
