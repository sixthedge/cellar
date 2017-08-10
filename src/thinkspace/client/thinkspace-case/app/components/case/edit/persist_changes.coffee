import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend
  
  model:       null ## Assignment
  assessments: null
  loader_key:  null
  type:        null ## 'rat' or 'pe' to determine which phase components to get

  is_rat: ember.computed.equal 'type', 'rat'
  is_pe:  ember.computed.equal 'type', 'pe'

  load_assessments: ->
    new ember.RSVP.Promise (resolve, reject) =>
      model = @get('model')
      path  = @get_path_str()

      query =
        id: model.get('id')
        componentable_type: ns.to_p(path)
      options =
        action: 'phase_componentables'
        model: ns.to_p(path)

      @tc.query_action(ns.to_p('assignment'), query, options).then (assessments) =>
        resolve()

  get_path_str: -> if @get('is_rat') then 'ra:assessment' else 'assessment'

  actions:
    explode: ->
      model      = @get('model')
      loader_key = @get('loader_key')

      query =
        id: model.get('id')

      options =
        action: 'explode'
        verb:   'PUT'
        model:  ns.to_p('assignment')

      @sendAction('set_loading', loader_key) if ember.isPresent(loader_key)
      @tc.query_action(ns.to_p('assignment'), query, options).then (assignment) =>
        @load_assessments().then =>
          @totem_messages.api_success source: @, model: @get('model'), action: 'explode', i18n_path: ns.to_o(@get_path_str(), 'explode')
          , (error) => 
            totem_messages.api_failure error, source: @, model: @get('model'), action: 'explode'
          @sendAction('reset_loading', loader_key) if ember.isPresent(loader_key)

    revert: ->
      assessments = ember.makeArray(@get('assessments'))
      loader_key  = @get('loader_key')

      @sendAction('set_loading', loader_key) if ember.isPresent(loader_key)

      promises = ember.makeArray()
      assessments.forEach (assessment) =>
        assessment.set('transform', null) if assessment.get('has_transform')
        promises.pushObject(assessment.save())

      ember.RSVP.all(promises).then (assessments) =>
        @totem_messages.api_success source: @, model: @get('model'), action: 'revert', i18n_path: ns.to_o(@get_path_str(), 'revert')
        , (error) =>
          totem_messages.api_failure error, source: @, model: @get('model'), action: 'revert'
        @sendAction('reset_loading', loader_key) if ember.isPresent(loader_key)