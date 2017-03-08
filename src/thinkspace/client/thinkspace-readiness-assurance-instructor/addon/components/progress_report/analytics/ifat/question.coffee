import ember       from 'ember'
import base        from 'thinkspace-readiness-assurance-instructor/components/base'

export default base.extend
  # ### Properties
  tagName:     'div' # Override the base component.

  model:      null # Object of the question from the assessment.
  assessment: null # Assessment that holds the question.
  choices:    null # Number of possible choices.
  data:       null

  # ### Computed properties
  question:        ember.computed.reads 'model'
  progress_report: ember.computed.reads 'am.data_values.progress_report'

  correct_total:         ember.computed.reads 'correct.total'
  correct_total_choices: ember.computed.reads 'correct.total_choices'
  correct_label:         ember.computed.reads 'correct.label'
  correct_average:       ember.computed.reads 'correct.average'
  
  # ### Observers
  changed_pr_observer: ember.observer 'am.data_values.progress_report', ->  @update_correct_and_percentages()

  init_base: ->
    console.log "[question] Initial question: ", @get('model')
    @update_correct_and_percentages()

  update_correct_and_percentages: ->
    id          = @get('model.id')
    data        = @am.get_progress_report_data_for_question_id(id)
    correct     = data.choices.findBy('correct', true)
    choices     = data.choices.sortBy('order')
    @set('data', data)
    @set('correct', correct)
    @set('choices', choices)

  set_is_expanded:    -> @set('is_expanded', true)
  reset_is_expanded:  -> @set('is_expanded', false)
  toggle_is_expanded: -> @toggleProperty('is_expanded')

  click: (e) -> @toggle_is_expanded()