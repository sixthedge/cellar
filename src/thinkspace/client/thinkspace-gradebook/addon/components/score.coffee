import ember from 'ember'
import ns    from 'totem/ns'
import util  from 'totem/util'
import base  from 'thinkspace-base/components/base'
import totem_changeset from 'totem/changeset'

export default base.extend

  gradebook:      ember.inject.service()
  changeset:      null
  td_error_class: 'error'

  score_change: ember.computed 'changeset.change', ->
    @update_table_class()
    return false if @changeset.get('is_invalid') or ember.isBlank @changeset.get('changes')
    Number(@changeset.get('model.score')) != Number(@changeset.get('score'))

  init_base: ->
    @get('gradebook').register_change_component(@)
    @set_changeset()

  register_change_callback: (change={}) -> @set_changeset()

  actions:
    save: ->
      return unless @changeset.get('is_valid')
      phase = @get('model')
      score = @changeset.get('score')
      @sendAction 'save', phase, score

  didInsertElement: -> @$('input').focus()

  set_changeset: ->
    # Not using the actual model in the changeset since Rails BigDecimal always includes at least one
    # decimal in the score. Sets the score decimals to match the phase's decimal validation rule, however,
    # this is not done when there are more decimals then allowed e.g. score decimals reduced in the phase
    # but an existing score has more decimals.
    phase       = @get 'model'
    phase_state = phase.get 'phase_state'
    return unless ember.isPresent(phase_state)
    decimals = @get('gradebook').get_phase_score_decimals(phase)
    phase_state.get(ns.to_p 'phase_score').then (phase_score) =>
      score = if ember.isBlank(phase_score) then '' else phase_score.get('score')
      if ember.isPresent(score)
        dv    = util.decimal_value(score)
        len   = (dv + '').length
        score = Number(score).toFixed(decimals) unless (len > decimals and dv != 0)
      phase_score = ember.Object.create(score: score)
      @set 'changeset', totem_changeset.create phase_score, score: @get_score_validators(phase)
      @changeset.show_errors_on()
      @changeset.validate().then => @update_table_class()

  get_score_validators: (phase) ->
    rules = @get('gradebook').get_phase_score_validation(phase)
    totem_changeset.number_validators(rules)

  update_table_class: ->
    return unless @table_score # 'table_score' is passed via template component helper
    $td = @$().parent('td')
    if @changeset.get('is_valid') then $td.removeClass(@td_error_class) else $td.addClass(@td_error_class)
