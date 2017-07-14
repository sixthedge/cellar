import ember from 'ember'
import base  from 'thinkspace-base/components/base'

###
# # settings.coffee
- Type: **Component**
- Package: **ethinkspace-builder-pe**
###
export default base.extend
  builder: ember.inject.service()
  manager: ember.inject.service()

  model: ember.computed.reads 'builder.model'
  step:  ember.computed.reads 'builder.step_settings'

  phases: ember.computed.reads 'step.model.active_phases'

  display_incorrect: ember.computed 'comp_incorrect', -> @get('comp_incorrect') * -1

  comp_correct: ember.computed 'step.irat_assessment.transform', 'step.irat_assessment.settings', ->
    path = @get_column('irat', 'settings.scoring.correct')
    @get_assessment_path('irat', path)

  comp_no_answer: ember.computed 'step.irat_assessment.transform', 'step.irat_assessment.settings', ->
    path = @get_column('irat', 'settings.scoring.no_answer')
    @get_assessment_path('irat', path)

  comp_ifat: ember.computed 'step.trat_assessment.transform', 'step.trat_assessment.settings', ->
    path = @get_column('trat', 'settings.questions.ifat')
    @get_assessment_path('trat', path)

  comp_attempted: ember.computed 'step.trat_assessment.transform', 'step.trat_assessment.settings', ->
    path = @get_column('trat', 'settings.scoring.attempted')
    @get_assessment_path('trat', path)

  comp_incorrect: ember.computed 'step.trat_assessment.transform', 'step.trat_assessment.settings', ->
    path = @get_column('trat', 'settings.scoring.incorrect_attempt')
    @get_assessment_path('trat', path)

  comp_justification: ember.computed 'step.irat_assessment.transform', 'step.irat_assessment.settings', ->
    path = @get_column('irat', 'settings.questions.justification')
    @get_assessment_path('irat', path)

  get_column: (type, col) -> @get('manager').get_column(type, col)
  get_assessment_path: (type, path) -> @get("step.#{type}_assessment.#{path}")