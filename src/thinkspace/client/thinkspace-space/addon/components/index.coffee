import ember from 'ember'
import ns    from 'totem/ns'
import base  from 'thinkspace-base/components/base'

import pm_state    from 'npm:prosemirror-state'
import pm_view     from 'npm:prosemirror-view'
import pm_model    from 'npm:prosemirror-model'
import pm_schema   from 'npm:prosemirror-schema-basic'
import pm_ex_setup from 'npm:prosemirror-example-setup'

export default base.extend
  totem_data_config: ability: {ajax_source: ns.to_p('spaces')}, metadata: true

  all_spaces: ember.computed.reads 'model'
  
  didInsertElement: ->
    console.log "IS TRUE?: ", document.querySelector('#content') == @$('#content').first()
    console.log "QS:       ", document.querySelector('#content')
    console.log "$:        ", @$('#content')[0]

    content = @$('#content')[0] #document.querySelector('#content') # @$('#content').first()
    editor  = @$('#editor')[0] #document.querySelector('#editor') # @$('#editor').first()
    schema  = pm_schema.schema

    console.log "PM VIEW: ", pm_view

    view = new pm_view.EditorView editor,
      state: pm_state.EditorState.create
        doc:     pm_model.DOMParser.fromSchema(schema).parse(content)
        plugins: pm_ex_setup.exampleSetup({schema})

    #console.log "VIEW: ", view
