import ember from 'ember'
import ns    from 'totem/ns'
import base_component from 'thinkspace-base/components/base'

export default base_component.extend

  # ### Properties
  tagName:           'span'
  classNames:        ['text__font-size--12', 'text--bold', 'text__transform--capitalize']
  classNameBindings: ['status_class_name']

  # ### Computed Properties
  is_complete:    ember.computed.equal 'model', 'complete'
  is_ignored:     ember.computed.equal 'model', 'ignored'
  is_in_progress: ember.computed.equal 'model', 'in-progress'
  is_not_started: ember.computed.equal 'model', 'not started'

  status_class_name: ember.computed 'model', ->
    return 'text__color--green' if @get('is_complete')
    return 'text__color--red text__font-style--italic' if @get('is_ignored')
    return 'text__color--blue' if @get('is_in_progress')
    return 'text__color--gray' if @get('is_not_started')