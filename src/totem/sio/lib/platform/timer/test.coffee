class SocketIOTimerTest

  # Test data for the timer module.
  # ###
  # ### TESTING ONLY

  # ******SAMPLE DATA**************
  #   action: 'rooms',
  #   rooms: 
  #    [ 'thinkspace/casespace/assignment/1/thinkspace/common/user/10',
  #      'thinkspace/casespace/assignment/1/thinkspace/common/user/11',
  #      'thinkspace/casespace/assignment/1/thinkspace/common/user/12' ],
  #   room_event: 'server_event',
  #   timer: 
  #    { type: 'countdown',
  #      unit: 'minute',
  #      interval: '1',
  #      title: 'some title',
  #      room_event: 'timer',
  #      end_at: '2016-06-12 18:34:50 UTC' },
  #   timer: #=> for server (e.g. rails server) redis publish for a cancel
  #    { type: 'cancel',
  #      cancel_ids: [1, 2], (or cancel_id: 1) }
  #   value: 
  #    { complete_phase_ids: [ 1 ],
  #      unlock_phase_ids: [ 2 ],
  #      transition_to_phase_id: 2,
  #      event: 'transition_to_phase',
  #      source_id: 'thinkspace/pub_sub/server_event/189' } }
  # ******************************

  test_uid: (uid, data) -> data.value.timer.user_id = uid; data

  once1: -> @test_once(end_at: 30, testname: 'once1')
  
  countdown1: -> @test_countdown(end_at: 10, testname: 'countdown1')
  countdown2: -> @test_countdown(end_at: 10, inc: 3, testname: 'countdown2-inc=3')
  countdown3: -> @test_countdown(start_at: 15, end_at: 20, testname: 'countdown3')
  countdown4: -> @test_countdown(start_at: 15, end_at: 20, testname: 'countdown4')

  countup1: -> @test_countup(end_at: 10, testname: 'countup1')
  countup2: -> @test_countup(start_at: 15, end_at: 20, testname: 'countup2')
  countup3: -> data = @test_countup(end_at: 10, testname: 'countup3'); data.value = {source_id: data.value.source_id, timer: data.value.timer}; data

  list1: -> @test_countdown(unit: 'minute', end_at: 7, testname: 'list1-7min', user_id: 5, model_id: 1)
  list2: -> @test_countdown(unit: 'minute', end_at: 10, testname: 'list2-10min', user_id: 5, inc: 3, model_id: 2)

  super1: -> @test_countdown(unit: 'minute', end_at: 5, inc: 3, testname: 'super1', user_id: 1)
  super2: -> @test_countdown(unit: 'minute', end_at: 6, inc: 3, testname: 'super2', user_id: 2)
  super3: -> @test_countdown(unit: 'minute', end_at: 7, inc: 3, testname: 'super3', user_id: 3)
  super4: -> @test_countdown(unit: 'minute', end_at: 8, inc: 3, testname: 'super4', user_id: 4)

  test_once:      (options) -> options.type = 'once'; @test_base(options)
  test_countdown: (options) -> options.type = 'countdown'; @test_base(options)
  test_countup:   (options) -> options.type = 'countup'; @test_base(options)

  test_cancel: (type='countdown') ->
    data = @test_base()
    data.value.timer = {type: 'cancel', cancel_id: "thinkspace/pub_sub/server_event/#{type}"}
    data


  test_reminders: (options={})->
    testname = options.testname or 'auto-testname'
    case_id  = options.case_id  or 1

    # timer setup (defaults: countdown timer for 100 seconds with reminder every 10 seconds)
    user_id          = options.user_id  or 3  # staging read_1
    unit             = options.unit     or 'second'
    start_at         = options.start_at or 0
    end_at           = options.end_at   or 100
    inc              = options.inc      or 10
    type             = options.type     or 'countdown'
    message          = options.message  or "Test #{type} message will trigger in"
    id               = options.id       or type
    timer            = {}
    timer.user_id    = user_id
    timer.id         = "thinkspace/pub_sub/server_event/#{id}"  # Rails Thinkspace::PubSub::ServerEvent record id (s/b unique)
    timer.title      = "Timer for #{type} #{testname}"          # set by Rails controller in timer_settings.title (ra used assessment title)
    timer.type       = type
    timer.room_event = 'timer'
    timer.unit       = unit
    timer.interval   = inc
    timer.start_at   = @get_test_at(unit, start_at)
    timer.end_at     = @get_test_at(unit, end_at)
    timer.message    = message

    # value setup
    value         = {}
    value.event   = options.event   or 'timer'

    # data setup
    data            = {}
    data.rooms      = ["thinkspace/casespace/assignment/#{case_id}/thinkspace/common/user/#{user_id}"]
    data.room_event = 'server_event'
    data.room_type  = null
    data.value      = value
    data.timer      = timer

    data

  test_base: (options={})->
    type                         = options.type or 'countdown'
    unit                         = options.unit or 'second'
    inc                          = options.inc or 2
    eat                          = options.end_at
    sat                          = options.start_at
    testname                     = options.testname or ''
    user_id                      = options.user_id or 1
    model_id                     = options.model_id or 1
    data                         = {}
    data.rooms                   = ['thinkspace/casespace/assignment/1/thinkspace/common/user/10']
    data.room_event              = 'server_event'
    data.room_type               = '1234567890'
    value                        = {}
    value.complete_phase_id      = [1]
    value.unlock_phase_id        = [2]
    value.transition_to_phase_id = 2
    value.event                  = 'transition_to_phase'
    timer                        = {}
    timer.id                     = "thinkspace/pub_sub/server_event/#{type}"
    timer.type                   = type
    timer.title                  = "Timer for #{type} #{testname}"
    timer.room_event             = 'timer'
    timer.unit                   = unit
    timer.interval               = inc
    timer.end_at                 = if  unit == 'minute' then @test_at_minutes(eat) else @test_at_seconds(eat)
    timer.start_at               = (if unit == 'minute' then @test_at_minutes(sat) else @test_at_seconds(sat)) if sat
    timer.user_id                = user_id
    timer.model_id               = model_id
    timer.model_type             = 'thinkspace/readiness_assurance/assessment'
    data.value                   = value
    data.timer                   = timer
    data
 
  get_test_at: (unit, units) ->
    return null unless typeof(units) == 'number'
    return @test_at_minutes(units) if unit == 'minute'
    @test_at_seconds(units)

  test_at_seconds: (secs=30) ->
    d = new Date()
    d.setSeconds(d.getSeconds() + (secs))
    d.toString()

  test_at_minutes: (mins=5) ->
    d = new Date()
    d.setMinutes(d.getMinutes() + (mins))
    d.toString()

  # ### TESTING ONLY
  # ###

module.exports = SocketIOTimerTest
