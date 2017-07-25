import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  
  model:       null ## Assignment
  assessments: null

  init_base: ->
    console.log('initializing this component ? ')

  actions:
    explode: ->
      model = @get('model')
      query =
        id: model.get('id')

      options =
        action: 'explode'
        verb:   'PUT'
        model:  ns.to_p('assignment')

      @sendAction('set_loading', 'all')
      @tc.query_action(ns.to_p('assignment'), query, options).then (assignment) =>
        @sendAction('reset_loading', 'all')
        @sendAction('init_assessments')
        @totem_messages.api_success source: @, model: @get('model'), action: 'explode', i18n_path: ns.to_o('team_set', 'explode')
        , (error) => 
          totem_messages.api_failure error, source: @, model: @get('model'), action: 'explode'

    revert: ->
      assessments = ember.makeArray(@get('assessments'))

      assessments.forEach (assessment) =>
        assessment.set('transform', null) if assessment.get('has_transform')
        assessment.save().then (assessment) =>
          console.log('reverted assessment with assessemnt ', assessment)

      # assessment.set('transform', null) if assessment.get('has_transform')
      # assessment.save().then (assessment) =>
      #   console.log('reverted assesment with assessment ', assessment)

