import ember from 'ember'
import base  from 'thinkspace-case/components/show'
import ns    from 'totem/ns'

export default base.extend

  irat: null
  trat: null

  has_transform:      ember.computed.or 'has_irat_transform', 'has_trat_transform'
  has_irat_transform: ember.computed.notEmpty 'irat.transform'
  has_trat_transform: ember.computed.notEmpty 'trat.transform'

  init_base: ->
    console.log('i think this is where we are...')
    @init_assessments()

  init_assessments: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')

      query =
        id: model.get('id')
        componentable_type: ns.to_p('ra:assessment')
      options =
        action: 'phase_componentables'
        model: ns.to_p('ra:assessment')

      @tc.query_action(ns.to_p('assignment'), query, options).then (assessments) =>
        @set_assessments(assessments)
        resolve()

  ## Expects the standard RAT case of one of each irat and trat assessment
  set_assessments: (assessments) ->
    irat = assessments.findBy('is_irat', true)
    trat = assessments.findBy('is_trat', true)
    @set('irat', irat) if ember.isPresent(irat)
    @set('trat', trat) if ember.isPresent(trat)

  actions:
    set_loading:   (type) -> @set_loading(type); false
    reset_loading: (type) -> @reset_loading(type); false
    init_assessments:     -> @init_assessments()
