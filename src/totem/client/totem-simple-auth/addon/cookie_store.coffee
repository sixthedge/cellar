import ember             from 'ember'
import objects_are_equal from 'ember-simple-auth/utils/objects-are-equal'
import base              from 'ember-simple-auth/session-stores/base'

export default base.extend
  init: ->
    @bind_cookie_event()

  persist: (data) ->
    Cookies.set(@get_cookie_key(), data)
    @_lastData = @restore()
    @trigger_cookie_event()

  restore: ->
    json = Cookies.get(@get_cookie_key())
    JSON.parse(json)

  clear: ->
    Cookies.remove(@get_cookie_key())
    @_lastData = {}
    @trigger_cookie_event()

  trigger_cookie_event: -> localStorage.setItem @get_event_key(), new Date()

  bind_cookie_event: ->
    $(window).bind 'storage', (e) =>
      if e.originalEvent.key == @get_event_key() or e.key == @get_event_key()
        data = @restore()
        if !objects_are_equal(data, @_lastData)
          @_lastData = data
          @trigger 'sessionDataUpdated', data

  get_cookie_key: -> 'totem-cookie-store'
  get_event_key:  -> 'totem-cookie'
