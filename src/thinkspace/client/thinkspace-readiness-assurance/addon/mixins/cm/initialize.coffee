import ember from 'ember'

export default ember.Mixin.create

  readonly: ember.computed.reads 'rm.readonly'

  init: ->
    @_super(arguments...)
    @init_manager_properties()
    @init_question_hash_values()
    @init_response_path_values()
    @init_values()

  init_manager_properties: ->
    return

  init_question_hash_values: ->
    @qid = @get('question_hash.id')

  init_response_path_values: ->
    @chat_path = "chat.messages.#{@qid}"
