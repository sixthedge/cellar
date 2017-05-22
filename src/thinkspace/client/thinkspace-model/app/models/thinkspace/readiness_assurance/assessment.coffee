import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.has_many    'ra:responses', reads: {filter: true}
    ta.polymorphic 'authable'
  ),

  title:             ta.attr('string')
  question_settings: ta.attr() # Used in the QuestionMangers, etc.  Contains questions + settings.
  authable_id:       ta.attr('number')
  authable_type:     ta.attr('string')
  ra_type:           ta.attr('string')
  # below attributes only populated when on dashboard (e.g. admin)
  settings:  ta.attr()
  answers:   ta.attr()
  questions: ta.attr()

  is_irat: ember.computed.equal 'ra_type', 'irat'
  is_trat: ember.computed.equal 'ra_type', 'trat'
  is_ifat: ember.computed.equal 'settings.questions.ifat', true

  questions_with_answers: ember.computed 'questions', 'answers', ->
    questions = @get('questions')
    answers   = @get('answers')
    arr       = ember.makeArray()

    questions.forEach (question) =>
      question.answer = if ember.isPresent(answers) and ember.isPresent(answers.correct) and ember.isPresent(answers.correct[question.id]) then answers.correct[question.id]  else null
      arr.pushObject(question)
    arr

  remove_question_answers: ->
    questions = @get('questions')
    questions.forEach (question) =>
      delete question.answer

  get_question_ids: -> @get('questions').mapBy 'id'

  get_question_by_id: (id) -> @get('questions').findBy 'id', id
  get_answer_by_id:   (id) -> @get("answers.correct.#{id}")
