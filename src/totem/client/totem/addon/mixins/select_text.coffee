import ember from 'ember'

export default ember.Mixin.create

  init: ->
    @_super()
    # Optionally add events such as mouseUp based on option.
    # Can add other events selections in the future.
    @add_mouse_up_function() if @get('select_text')

  add_mouse_up_function: ->
    if (mouse_up = @mouseUp)
      logger.warn "SelectTextViewMixin: [#{@}] already has a mouseUp event.  Pre-pending this function."
      @mouseUp = 
        ( (event) ->
          @mouse_up_function(event)
          mouse_up(event)
        ) 
    else
      @mouseUp = @mouse_up_function

  mouse_up_function: (event) ->
    return unless @get('select_text')
    selObj = window.getSelection()  # Not x-browser or database backed
    value = selObj.toString()
    return unless value
    select_text_controllers = @get 'controller.select_text_controllers' or []
    for controller in select_text_controllers
      controller.process_select_text(value)
