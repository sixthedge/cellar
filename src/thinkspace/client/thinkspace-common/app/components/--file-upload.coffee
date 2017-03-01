import ember from 'ember'
import config from 'totem-config/config'
import base  from 'thinkspace-base/components/base'

## thinkspace_common file-upload 
# options:
#                    default value | purpose
#
# form_action                 null | url to send the http request after the file has been uploaded
# host_name        config.api_host | host to prepend to the form_action
# verb                      'POST' | request verb
# api_params                  null | additional params to send with the request, expecting format: [{key: 'id', value: 1}, { }..]
# btn_text                'Upload' | text to display on the button which opens the file uploader
# select_text     'Browse file(s)' | text to display on the button which allows the selection of files
# loading_text 'Uploading Files..' | text to display on the modal while the file is being added and the request is being sent
# modal_template              null | optional template name to render instead of the provided modal title and instructions
# drop                        true | allows for dragging and dropping of files onto the modal
# after_import                null | hook for after the data.submit promise has been successfully resolved
# close_on_success            true | closes the modal upon a successful file upload
# debug                      false | show fileupload console logs
##

export default base.extend
  layoutName:        'thinkspace/common/file_upload'
  classNameBindings: ['is_drag_hovered:drag-hovered']

  # options
  form_action:      null
  host_name:        null
  verb:             'POST'
  api_params:       null
  model_path:       null
  btn_text:         'Upload'
  select_text:      'Browse file(s)'
  loading_text:     'Uploading files..'
  drop:             true
  after_import:     null
  close_on_success: true
  debug:            false

  host:       ember.computed 'host_name', -> if @get('host_name') then return @get('host_name') else return config.api_host
  form_url:   ember.computed 'host', 'form_action', -> "#{@get('host')}#{@get('form_action')}"
  auth_token: ember.computed -> @container.lookup('simple-auth-session:main').get('secure.token')
  store:      ember.computed -> @container.lookup('store:main')
  input_id:   ember.computed -> "thinkspace-common_fu_input-#{@get('elementId')}"
  modal_id:   ember.computed -> "thinkspace-common_fu-modal-#{@get('elementId')}"

  upload_success: false
  upload_error:   false
  files:          ember.makeArray()

  show_success:      ember.computed 'upload_success', 'upload_error', -> @get('upload_success') and not @get('upload_error')
  show_error:        ember.computed 'upload_success', 'upload_error', -> @get('upload_error') and not @get('upload_success')
  show_instructions: ember.computed 'upload_success', 'upload_error', -> (not @get('upload_success')) and (not @get('upload_error'))

  # jquery selectors
  modal:      ember.computed 'modal_id', -> $("##{@get('modal_id')}")
  file_input: ember.computed 'input_id', -> $("##{@get('input_id')}")
  drop_zone:  ember.computed.alias 'modal'

  params_list: ember.computed 'api_params', ->
    list = []
    for k, v of @get('api_params')
      list.pushObject({key: k, value: v})
    list

  didInsertElement: ->
    $(document).foundation 'reveal'
    @initialize_fileupload()
    @add_listeners() if @get 'drop'

  initialize_fileupload: ->
    $input     = @get('file_input')
    $drop_zone = @get('drop_zone')

    $input.fileupload
      autoUpload: true
      dataType:   'json'
      dropZone:   $drop_zone
      fileInput:  $input

      # callback for when a file has been added
      add: (e, data) =>
        @debug_log 'add:', data
        @set 'processing', true
        @set 'server_response', null
        jqXHR = data.submit()

        jqXHR.success (result, textStatus, jqXHR) =>
          @set 'upload_error', false
          @set 'upload_success', true
          @get('after_import')(result) if @get 'after_import'
          @send('close_modal')         if @get 'close_on_success'

        jqXHR.error (jqXHR, textStatus, errorThrown) =>
          @set 'server_response', jqXHR.responseJSON.errors.user_message
          @set 'upload_error', true
          @set 'upload_success', false

        jqXHR.complete (result, textStatus, jqXHR) =>
          @set 'processing', false
          @debug_log textStatus, result

      # callback for when all files are done uploading
      done: (e, data) =>
        @debug_log 'done:', data
        @get('files').pushObjects(data.files)

        # content should be configurable to what controller property you want to use
        store      = @get 'store'
        model_path = @get 'model_path'

        return unless model_path

        key = model_path + 's'
        @tc.push_payload model_path, data.result

        # set ember associations from the payload
        for record in data.result[key]
          promises = ember.makeArray()
          promises.pushObject @tc.find_record(model_path, record.id)
          ember.RSVP.all(promises).then (records) =>
            if records.get('firstObject') and records.get('firstObject').add_to_all_relationships?
              promises = ember.makeArray()
              records.forEach (record) =>
                promises.pushObject record.add_to_all_relationships()
              ember.RSVP.all(records).then =>
                @set 'processing', false
            else
              @set 'processing', false

      change: (e, data) =>
        @debug_log 'change:', data

  add_listeners: ->

    # disables the default browser action for file drops on the document
    $(document).bind('drop dragover', (e) -> e.preventDefault())

    $drop_zone = @get 'drop_zone'
    $input = @get 'file_input'

    if $drop_zone
      $drop_zone.on 'dragover', ->
        $drop_zone.addClass('drag-hovered') unless $drop_zone.hasClass('drag-hovered')

      $drop_zone.on 'dragleave drop', ->
        $drop_zone.removeClass('drag-hovered') if $drop_zone.hasClass('drag-hovered')

  debug_log: (context, message) ->
    console.log "[fileupload-#{@get('elementId')}]", context, message if @get('debug')

  actions:

    close_modal: ->
      @get('modal').foundation 'reveal', 'close'

