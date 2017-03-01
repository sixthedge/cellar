import ember       from 'ember'
import base        from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  # ### Properties
  data:    null # JSON from the progress report for this question
  choices: null # Array of each choice with their relevant percentages.

  correct_color: '#5BBC61'
  colors:        [] # Array containing all possible colors.
  used_colors:   [] # Array containing all used colors.

  # Note: This could be bound to am.data_values.progress_report, but will be less performant.
  data_changed_observer: ember.observer 'data', -> @set_colors()

  init_base: ->
    @set_colors()

  set_colors: ->
    @reset_colors()
    data    = @get('data')
    choices = data.choices
    correct = choices.findBy('correct', true)
    @set('choices', choices)
    @set('correct', correct)
    
    choices.forEach (choice) =>
      if choice.correct
        choice.background_color = @get('correct_color')
      else
        choice.background_color = @get_choice_color(choice)

  reset_colors: -> 
    colors = ['#ee6055', '#ee6055', '#ee6055', '#ee6055']
    @set('colors', colors)

  get_choice_color: (choice) ->
    data    = @get('data')
    index   = data.choices.indexOf(choice)
    colors  = @get('colors')
    colors[index]