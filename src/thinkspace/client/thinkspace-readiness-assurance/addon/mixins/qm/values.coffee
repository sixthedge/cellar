import ember from 'ember'

export default ember.Mixin.create

  answer_id:        null
  answer:           null
  justification:    null
  response_updated: null  # does not change value, but components can observe for response changes

  init_values: ->
    @save_prev_values()
    @reset_values()

  reset_values: ->
    @set_answer()
    @set_justification()
    @set_status()
    @notify_response_updated()

  set_answer: ->
    answer_id = @get(@answer_path)
    @set 'answer_id', answer_id or null
    @set 'answer', (@choices.findBy('id', answer_id) or {}).label or null
    @call_callbacks('answer')  unless @prev_answer_id == answer_id

  set_justification: ->
    @set 'justification', @get(@justification_path) or null
    @call_callbacks('justification')  unless @prev_justification == @get('justification')

  save_prev_values: ->
    @save_prev_answer_id()
    @save_prev_justfication()

  save_prev_answer_id:    -> @prev_answer_id     = @get(@answer_path)
  save_prev_justfication: -> @prev_justification = @get(@justification_path)

  set_status: ->
    status = @get(@status_path) or {}
    locked = status.locked
    @set_scribe_values(locked) if @rm.is_scribeable
    if ember.isBlank(locked)
      @set_question_disabled_by(null)
      @set_question_disabled_off()
    else
      user_id = locked.id
      @error "Status locked 'id' is blank."  if ember.isBlank(user_id)
      if @rm.pubsub.is_current_user_id(user_id)
        @set_question_disabled_by_self()
      else
        name = "#{locked.first_name} #{locked.last_name}"
        @set_question_disabled_by(name)
        @set_question_disabled_on()

  set_scribe_values: (locked) ->
    id = if ember.isBlank(locked) then null else "#{locked.id}"
    @rm.set 'scribe_user_id', id unless @rm.get('scribe_user_id') == id

  # ###
  # ### Save User Values.
  # ###

  save_answer: (answer_id) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @save_prev_answer_id()
      @set(@answer_path, answer_id)
      @set_answer()
      @rm.save_response().then =>
        @notify_response_updated()
        resolve()

  save_justification: (value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      @save_prev_justfication()
      @set(@justification_path, value)
      @set_justification()
      @rm.save_response().then =>
        @notify_response_updated()
        resolve()

  notify_response_updated: -> @notifyPropertyChange 'response_updated'

  # ###
  # ### Question Change Callbacks.
  # ###

  call_callbacks: (key) ->
    @callbacks.forEach (method_array, source) =>
      if @is_active(source)
        for method in method_array
          source[method](@, key)  if @is_function(source[method])
      else
        @callbacks.delete(source)

  register_change_callback: (source, method) ->
    methods = @callbacks.get(source)
    if ember.isBlank(methods)
      @callbacks.set source, [method]
    else
      methods.push(method)
