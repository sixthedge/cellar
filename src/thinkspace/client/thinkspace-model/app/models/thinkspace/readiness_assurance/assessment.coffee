import ember from 'ember'
import ta    from 'totem/ds/associations'
import base  from '../common/componentable'

export default base.extend ta.add(
    ta.has_many    'ra:responses', reads: {filter: true}
    ta.polymorphic 'authable'
  ),

  title:             ta.attr('string')
  question_settings: ta.attr()
  authable_id:       ta.attr('number')
  authable_type:     ta.attr('string')
  ra_type:           ta.attr('string')
  scribeable:        ta.attr('boolean')
  # below attributes only populated when on dashboard (e.g. admin)
  settings: ta.attr()
  answers:  ta.attr()

  questions: ember.computed.reads 'question_settings'

  is_irat: ember.computed.equal 'ra_type', 'irat'
  is_trat: ember.computed.equal 'ra_type', 'trat'
  is_ifat: ember.computed.equal 'settings.questions.ifat', true

  get_question_ids: -> @get('questions').mapBy 'id'

  get_question_by_id: (id) -> @get('questions').findBy 'id', id
  get_answer_by_id:   (id) -> @get("answers.correct.#{id}")
