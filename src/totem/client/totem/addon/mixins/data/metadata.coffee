import ember from 'ember'
import base  from 'totem/mixins/data/base_module'

export default base.extend

  add: (metadata) ->
    unless @is_object(metadata)
      console.error "Must pass a 'key: value' object to #{@mod_name}.add() not:", metadata
      return
    ember.merge @added_metadata, metadata

  # ###
  # ### Private.
  # ###

  init_values: (source) ->
    @_super(source)
    @added_metadata = {}
    @totem_data.set_source_property('metadata')
    @set_data()

  set_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve()  unless @process_source_data()
      @get_metadata().then (metadata) =>
        @get_source().setProperties
          metadata: metadata
        resolve()

  get_metadata: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_data().then (metadata) =>
        metadata = {} if ember.isBlank(metadata)
        ember.merge metadata, @added_metadata
        @call_source_callback(metadata: metadata).then =>
          resolve(metadata)

  # ###
  # ### Print.
  # ###

  print_metadata: (options={}) ->
    @print_header()  unless options.header == false
    console.info 'METADATA ->'
    @print_data @get('metadata')
