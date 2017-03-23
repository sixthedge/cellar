import ember      from 'ember'
import e_uploader from 'ember-uploader'
import ns         from 'totem/ns'
import ajax       from 'totem/ajax'
import config     from 'totem-config/config'
import base       from 'thinkspace-base/components/base'

export default base.extend
  # # Properties
  classNames:        ['test-upload']
  classNameBindings: ['is_dragging:is-dragging']
  s3:                false
  authable:          null
  type:              null # Type of uploader to use on the server.
  model:             null # Model to use for pushing into the sotre.

  # # Computed properties
  # Override the `s3` property based on config (primarily for development).
  use_s3: ember.computed 's3', ->
    s3 = @get('s3')
    return false if s3 == false
    override = ember.get(config, 'uploader.s3')
    if ember.isPresent(override) then override else s3

  # ## Ember-Uploader properties
  url:         ajax.build_url(ns.to_p('upload'), null, null, 'upload')
  signing_url: ajax.build_url(ns.to_p('upload'), null, null, 'sign')
  param_name:  'files'

  # ## Drag properties
  is_dragging: false
  # Note: Using the counter for: http://stackoverflow.com/questions/7110353/html5-dragleave-fired-when-hovering-a-child-element
  # => Could also use pointer-events: none CSS on the children elements, but gives less flexibility.
  drag_counter: 0

  # # Events
  dragEnter: (event) -> event.preventDefault(); @offset_drag_counter(1)
  dragLeave: (event) -> event.preventDefault(); @offset_drag_counter(-1)
  # Avoid default browser functionality to allow drop.
  dragOver: (event) ->  event.preventDefault()
  drop:     (event) ->
    event.preventDefault()
    @reset_drag_counter()
    files = event.dataTransfer.files
    @send('files_changed', files)

  # # Drag helpers
  # ## Getters/setters
  offset_drag_counter: (offset) ->
    counter = @get('drag_counter')
    count   = counter + offset
    @set_drag_counter(count)

  update_is_dragging: ->
    count = @get('drag_counter')
    if count == 0 then @reset_is_dragging() else @set_is_dragging()

  reset_is_dragging:  -> @set('is_dragging', false)
  set_is_dragging:    -> @set('is_dragging', true)
  reset_drag_counter: -> @set_drag_counter(0)
  set_drag_counter:   (count) -> @set('drag_counter', count); @update_is_dragging()

  # # Upload
  upload: (files) ->
    use_s3 = @get('use_s3')
    if use_s3 then @upload_s3(files) else @upload_api(files)

  upload_api: (files) ->
    uploader = e_uploader.Uploader.create
      url:          @get('url')
      paramName:    @get('param_name')
      ajaxSettings: @get_ajax_settings()
    @add_uploader_callbacks(uploader)
    options = @get_uploader_options()
    uploader.upload(files, options).then (e) =>
      @uploader_complete_direct(e, options)

  upload_s3: (files) ->
    # Currently, for S3 with ember-uploader, you must upload/sign each file individually.
    # Files will look like:  FileList {0: File, length: 1}, it is *not* an array.
    length = files.length
    for i in [0..(length - 1)]
      file = files[i]
      uploader = e_uploader.S3Uploader.create
        signingUrl:          @get('signing_url')
        signingAjaxSettings: @get_ajax_settings()
      @add_uploader_callbacks(uploader)
      options = @get_uploader_options()
      uploader.upload(file, options).then (e) =>
        @uploader_complete_s3(e, options)

  get_uploader_options: ->
    type             = @get('type')
    authable         = @get('authable')
    authable_type    = @totem_scope.standard_record_path(authable)
    authable_id      = authable.get('id')
    uploader_options = {type: type, authable: {id: authable_id, type: authable_type}}
    {uploader: JSON.stringify(uploader_options)}

  add_uploader_callbacks: (uploader) ->
    uploader.on 'progress', (e)                                => @uploader_progress(e)
    uploader.on 'didError', (jqXHR, text_status, error_thrown) => @uploader_error(jqXHR, text_status, error_thrown)

  uploader_complete_direct: (payload, options) ->
    console.log "[file_upload] `upload_complete_direct`: ", payload, options
    @process_payload(payload, options)

  uploader_complete_s3: (e, options) ->
    console.log "[file_upload] `upload_complete_s3`: ", e, options
    $e     = $(e)
    url    = $e.find('Location')[0].textContent
    bucket = $e.find('Bucket')[0].textContent
    key    = $e.find('Key')[0].textContent
    query = options
    query.aws = 
      url:     url
      bucket:  bucket
      key:     key
    query_options = 
      verb:   'POST'
      action: 'confirm'
    @tc.query_data(ns.to_p('upload'), query, query_options).then (payload) =>
      @process_payload(payload, options)

  process_payload: (payload, options={}) ->
    console.log "[file_upload] `process_payload` called: ", payload, options
    if payload.raw
      response = payload
    else
      type     = @get('model')
      response = @tc.push_payload_and_return_records_for_type(payload, type)
    @reset_input()
    @sendAction('response', response)

  uploader_progress: (e) ->
    console.log "[file_upload] `upload_progress`: ", e

  uploader_error: (jqXHR, text_status, error_thrown) ->
    console.log "[file_upload] `upload_error`: ", jqXHR, text_status, error_thrown

  # # Misc. helpers
  # ## Getters/setters
  # Need to add the authorization headers to the Ember.$.ajax called by ember-upload.
  get_ajax_settings: ->
    settings = {}
    ajax.add_auth_headers(settings)
    settings

  # ## Input helpers
  reset_input: -> @$('input[type="file"]').val(null)

  actions:
    # `files_changed` is called by the input when the browser selects a file OR via this component's drop.
    files_changed: (files) -> @upload(files)