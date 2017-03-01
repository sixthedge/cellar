import ds from 'ember-data'
import ts from 'totem/scope'
import tc from 'totem/cache'
import ti from 'totem-engines/initializer'

initializer = 
  name:       'totem'
  initialize: (app) ->

    # Add totem scope to base ember-data model for filtering on path_ids.
    # Add totem cache to base ember-data model for store based functions.
    ds.Model.reopen
      totem_scope: ts
      tc:          tc

    ti.initialize(app)

export default initializer
