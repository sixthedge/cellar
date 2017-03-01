import ember from 'ember'
import ns    from 'totem/ns'

initializer =
  name:  'thinkspace-authorization-metadata'
  after: ['totem']
  initialize: (app) ->

    # Prevent singular of 'thinkspace/authorization/metadata' and 'metadata' being metadatum.
    metadata = 'metadata'
    path     = ns.to_p 'authorization', metadata
    ember.Inflector.inflector.irregular(path, path)
    ember.Inflector.inflector.irregular(metadata, metadata)

export default initializer
