import ember       from 'ember'
import base        from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  # ### Properties
  data:     null # JSON from the progress report for this question
  choices:  null # Array of each choice with their relevant percentages.
  correct:  null # Object of the correct choice
  attempts: null # Array of attempts for correct answer

  colors:        [] # Array containing all possible colors.
  used_colors:   [] # Array containing all used colors.

  # Note: This could be bound to am.data_values.progress_report, but will be less performant.
  data_changed_observer: ember.observer 'data', -> @set_colors()

  init_base: ->
    @set_colors()

  set_colors: ->
    @reset_colors()
    data     = @get('data')
    choices  = data.choices
    correct  = choices.findBy('correct', true)
    attempts = correct.attempts.sortBy('attempt')

    @set('attempts', attempts)
    @set('choices', choices)
    @set('correct', correct)
    
    attempts.forEach (attempt) =>
      attempt.background_color = @get_attempt_color(attempt)

  reset_colors: -> 
    colors = ['#3b9040', '#5BBC61', '#91d295', '#b6e1b8']
    @set('colors', colors)

  get_attempt_color: (attempt) ->
    attempts = @get('attempts')
    index    = attempts.indexOf(attempt)
    colors   = @get('colors')
    colors[index]