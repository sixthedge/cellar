import ember       from 'ember'
import ns          from 'totem/ns'
import tc          from 'totem/cache'
import ajax        from 'totem/ajax'
import totem_scope from 'totem/scope'
import question_manager from 'thinkspace-readiness-assurance/managers/question'
import chat_manager     from 'thinkspace-readiness-assurance/managers/chat'

export default ember.Mixin.create

  ready: false

  # Set in response_manager.create().
  store:  null
  tvo:    null
  ttz:    null
  pubsub: null
  se:     null

  question_manager_map: null
  chat_manager_map:     null

  init: ->
    @_super(arguments...)
    @tc = tc # set tc as object property

  init_manager: (options={}) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @init_manager_properties(options)
      @init_assessment(options)
      @init_response_models(options).then =>
        @init_random_choices(options)
        @init_question_managers(options)
        @init_room(options)
        if @is_trat
          @init_chat_managers(options)
          @init_room_users(options).then =>
            @set 'ready', true
            resolve(@)
          , (msg) => @error(msg)
        else
          @set 'ready', true
          resolve(@)
      , (msg) =>
        @error(msg)

  # ###
  # ### Manager Properties.
  # ###

  init_manager_properties: (options) ->
    @init_maps(options)
    @init_readonly(options)
    @init_can_update_assessment(options)
    @init_ra_type(options)
    @set 'ready', false
    @save_error     = false
    @current_user   = totem_scope.get_current_user()
    @title          = options.title or options.username or  'unknown'
    @ownerable_id   = options.ownerable_id   || ''
    @ownerable_type = options.ownerable_type || ''
    @is_admin       = options.admin or false
    @save_to_server = not (options.save_response == false)

  init_maps: (options) ->
    @question_manager_map = ember.Map.create()
    @chat_manager_map     = ember.Map.create()

  init_readonly: (options) ->
    @readonly   = (options.readonly == true)
    @updateable = not @readonly

  init_can_update_assessment: (options) ->
    @can_update_assessment    = options.can_update_assessment or false
    @cannot_update_assessment = not @can_update_assessment

  init_ra_type: (options) ->
    @is_irat = options.irat or false
    @is_trat = options.trat or false
    @error "Both required option 'irat' or 'trat' are blank. Add either 'irat: true' or 'trat: true'."  if not @is_irat and not @is_trat
    @error "Both 'irat' or 'trat' options are present.  Specify only one."  if @is_irat and @is_trat

  # ###
  # ### Models.
  # ###

  init_assessment: (options) ->
    @assessment = options.assessment
    @error "Required assessment model in 'options.model' is blank."  if ember.isBlank(@assessment)

  init_response_models: (options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @init_response(options).then =>
        @init_status().then =>
          return resolve() unless @is_trat
          @init_chat().then =>
            resolve()
          , (msg) => reject(msg)
        , (msg) => reject(msg)
      , (msg) => reject(msg)

  init_response: (options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      response = options.response
      if ember.isPresent(response)
        @response = response
        return resolve()
      @tc.view_load(@assessment).then (response) =>
        @response = @assessment.get('responses.firstObject')  # from filtered by ownerable association records
        return resolve() if ember.isPresent(@response)
        msg = "Assessment model [id: #{@assessment.get('id')}] response is blank #{@ownerable_error_message()}."
        reject(msg)

  init_status: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @response.get(ns.to_p 'ra:status').then (status) =>
        @status = status
        return resolve() if ember.isPresent(@status)
        msg = "Assessment model [id: #{@assessment.get('id')}] status is blank for response [id: #{@response.get('id')}] #{@ownerable_error_message()}."
        reject(msg)

  init_random_choices: (options) ->
    @random_choices   = options.random_choices or false
    @random_by_client = options.random_by_client or false

  init_question_managers: (options) ->
    qn    = 0
    @qids = []
    for question in @assessment.get('question_settings')
      qn += 1
      qm = question_manager.create
        question_hash: question
        rm:            @
        response:      @response
        status:        @status
        qn:            qn
      id = question.id
      @error "Assessment [id: #{@assessment.get('id')}] question 'id' is blank.", question  if ember.isBlank(id)
      @error "Assessment [id: #{@assessment.get('id')}] question id '#{id}' is a duplicate.", question  if @qids.contains(id)
      @qids.push(id)
      @question_manager_map.set id, qm

  init_room: (options) ->
    @join_server_event_received_event()
    @room = @init_get_room(options)
    if @is_trat and @room
      @room_users_header = options.room_users_header
      @pubsub.join room: @room
      @join_response_received_event()
      @join_status_received_event()
      @join_chat_received_event()

  init_get_room: (options) ->
    room = options.room or null
    room = @se.phase_ownerable_room() if @is_trat and ember.isBlank(room)
    room

  # ###
  # ### TRAT.
  # ###

  init_chat: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @response.get(ns.to_p 'ra:chat').then (chat) =>
        @chat = chat
        return resolve() if ember.isPresent(@chat)
        msg = "Assessment model [id: #{@assessment.get('id')}] chat is blank for response [id: #{@response.get('id')}] #{@ownerable_error_message()}."
        reject(msg)

  init_room_users: (options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      room_users = options.room_users
      if ember.isPresent(room_users)
        @room_users = room_users
        return resolve()
      model      = @assessment
      id         = model.get('id')
      action     = 'teams'
      verb       = 'post'
      query      = {model, id, action, verb}
      ajax.object(query).then (data) =>
        return reject("Team room users are blank.")      if (!data or data.length < 1) and @cannot_update_assessment
        return rejest("More than one team room users.")  if data.length > 1
        @room_users = (data.get('firstObject') or {}).users
        resolve()
      , (error) => reject(error)

  init_chat_managers: (options) ->
    for question in @assessment.get('question_settings')
      cm = chat_manager.create
        question_hash: question
        rm:            @
        chat:          @chat
        status:        @status
      id = question.id
      @error "Assessment [id: #{@assessment.get('id')}] question 'id' is blank.", question  if ember.isBlank(id)
      @chat_manager_map.set id, cm

  # ###
  # ### Init Helpers.
  # ###

  ownerable_error_message: ->
    ownerable = totem_scope.get_ownerable_record()
    id        = ownerable.get('id')
    type      = totem_scope.get_record_path(ownerable)
    "for ownerable [type: #{type} ] [id: #{id}]"
