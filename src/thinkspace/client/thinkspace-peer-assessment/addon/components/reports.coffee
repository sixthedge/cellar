import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

export default base.extend

  reports_visible: true

  dropdown_collection: ember.computed ->
    collection = []
    collection.push {display: 'Ownerable Data', report_type: 'ownerable_data'}
    collection

  actions:
    done: ->
      @get('thinkspace').transition_to_route 'cases.show', @get('model')

  init_base: ->
    tvo = @get('tvo')
    tvo.clear()
    hash = @get_report_values()
    tvo.value.set_value(hash)

  get_report_values: ->
    model       = @get('model')
    hash        = {}
    hash.title  = 'thinkspace-report'
    hash.model  = model
    hash.values =
      report_dropdown: @get('dropdown_collection')
    hash
