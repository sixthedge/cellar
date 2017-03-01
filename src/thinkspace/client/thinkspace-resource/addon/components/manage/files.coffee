import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import base  from 'thinkspace-base/components/base'

export default base.extend

  c_manage_file: ns.to_p 'resource', 'manage', 'file'

  files_url:  ember.computed -> ajax.adapter_model_url(model: ns.to_p 'file')
  model_type: ember.computed -> @totem_scope.record_type_key(@get('model'))

  is_drag_hovered: false
  is_uploading:    false

  actions:
    close: -> @sendAction 'close'

  didInsertElement: ->
    # Selectors used by jQuery File Upload
    selector_expansion    = '.thinkspace-resource_expansion'
    selector_drop_zone    = '.thinkspace-resource_drop-zone' # <div> where the droppable is set to handle files.
    selector_upload_input = '.thinkspace-resource_upload-input' # <input> that handles the POSTing.
    selector_upload_list  = '.thinkspace-resource_upload-list' # <ul> containing uploaded files.

    # Selectors for templates used by jQuery File Upload
    selector_uploaded_item       = '.thinkspace-resource_uploaded-item' # <li> representing a transfer.
    selector_completed_state     = '.is-completed' # class to mark finished transfers.
    selector_upload_progress_bar = '.thinkspace-resource_upload-progress-bar' # <div> that houses the expanding bar that gets set by the progress callback.

    # Templates used by jQuery File Upload
    template_uploaded_item  = '<li class="thinkspace-resource_uploaded-item">#PROGRESS_BAR#</li>'
    template_progress_bar   = '<div class="thinkspace-resource_upload-progress-bar-wrapper"><div class="thinkspace-resource_upload-progress-bar">Uploading #FILE_NAME#</div></div>'
    template_completed_icon = '<i class="fa fa-check"></i>'

    @$(selector_expansion).on 'dragover',       => @set('is_drag_hovered', true)  unless @get('is_drag_hovered')
    @$(selector_drop_zone).on 'dragleave drop', => @set('is_drag_hovered', false) if @get('is_drag_hovered')

    $input = @$().find(selector_upload_input).first()
    url    = ajax.adapter_model_url(model: ns.to_p 'file')

    $input.fileupload
      url:      url
      dataType: 'json'
      dropZone: $(selector_drop_zone)

      done: (e, data) =>
        # data.uploaded_item is the jQuery div wrapping the upload progress bar.
        model = @get('model')
        # Load the payload.
        key = ns.to_p('files')
        @tc.push_payload(ns.to_p('file'), data.result)
        for file in data.result[key]
          @tc.find_record(ns.to_p('file'), file.id).then (file) =>
            model.get(key).then (files) =>
              files.pushObject(file) unless files.contains(file)
        @set('is_uploading', false) if @get('is_uploading')

      drop: (e, data) =>
        @set('is_uploading', true) unless @get('is_uploading')

      add: (e, data) =>
        @set('is_uploading', true) unless @get('is_uploading')
        $upload_list = @$(selector_upload_list)
        data.files.forEach (file) =>
          progress_bar       = template_progress_bar.replace('#FILE_NAME#', file.name)
          uploaded_item      = template_uploaded_item.replace('#PROGRESS_BAR#', progress_bar)
          $uploaded_item     = $(uploaded_item)
          $upload_list.prepend($uploaded_item)
          data.uploaded_item = $uploaded_item
        data.submit()

      progress: (e, data) =>
        progress      = parseInt(data.loaded / data.total * 100, 10)
        $active_row   = data.uploaded_item
        $progress_bar = $active_row.find(selector_upload_progress_bar)
        $active_row.remove() if progress == 100
        $progress_bar.css('width', progress + '%')


