import ember from 'ember'

export default ember.Mixin.create

  readonly: ember.computed.reads 'rm.readonly'

  init: ->
    @_super(arguments...)
    @init_manager_properties()
    @init_question_hash_values()
    @init_response_path_values()
    @init_choices()
    @init_values()

  init_manager_properties: ->
    @callbacks = ember.Map.create()

  init_question_hash_values: ->
    @qid      = @get('question_hash.id')
    @question = @get('question_hash.question')
    @qchoices = @get('question_hash.choices')
    @qrandom  = @get('question_hash.questions.random')
    @is_ifat  = @get('question_hash.questions.ifat') == true
    @has_justification = @get('question_hash.questions.justification') == true

  init_response_path_values: ->
    @answer_path        = "response.answers.#{@qid}"
    @justification_path = "response.justifications.#{@qid}"
    @status_path        = "status.questions.#{@qid}"
    @random_path        = "status.settings.choices.order.#{@qid}"

  # 'rm.random_by_client' or 'rm.random_choices' (from the rm initialize options) overrides any other value and applies to all questions
  init_choices: ->
    if @rm.random_by_client or @qrandom == 'client'
      @choices = @randomize_choices()
      return
    random = @rm.random_choices or @qrandom
    if ember.isBlank(random) or random == false  # false or not set in rm or in question hash
      @choices = @qchoices
      return
    ids      = @get @random_path   # status.settings.choices[qid]
    @choices = if ember.isPresent(ids) then @init_random_choices(ids) else @randomize_choices()

  init_random_choices: (ids) ->
    random_choices = []
    for id in ids
      choice = @qchoices.findBy('id', id)
      @error "Choice id '#{id}' not found in assessment choices."  unless choice
      random_choices.push(choice)
    @validate_random_choices(random_choices)
    random_choices

  validate_random_choices: (random_choices) ->
    for choice in @qchoices
      id    = choice.id
      found = random_choices.findBy('id', id)
      # FWIW: if not found, could just add to the random choices rather than generating an error
      @error "Choice id '#{id}' not included in random choices."  unless found

  randomize_choices: ->
    return [] if ember.isBlank(@qchoices)
    length = @qchoices.length
    return @qchoices unless length > 1
    irandom = [0..(length-1)]
    for i in [0..(length-1)]
      ri          = Math.floor Math.random() * i
      temp        = irandom[i]
      irandom[i]  = irandom[ri]
      irandom[ri] = temp
    (@qchoices[i] for i in irandom)
