import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

###
# # reports.coffee
- Type: **Component**
- Package: **thinkspace-peer-assessment**
###
export default base.extend
  # ## Properties
  # ### Internal Properties
  reports_visible: true

  # ### Computed Properties
  dropdown_collection: ember.computed ->
    collection = []
    collection.push {display: 'Ownerable Data', report_type: 'ownerable_data'}
    collection

  # ## Events
  init_base: ->
    tvo = @get('tvo')
    tvo.clear()
    hash = @get_report_values()
    tvo.value.set_value(hash)

  # ## Helpers
  get_report_values: ->
    model       = @get('model')
    hash        = {}
    hash.title  = 'thinkspace-report'
    hash.model  = model
    hash.values =
      report_dropdown: @get('dropdown_collection')
    hash

  # ## Actions
  actions:
    done: ->
      @get('thinkspace').transition_to_route 'cases.show', @get('model')


