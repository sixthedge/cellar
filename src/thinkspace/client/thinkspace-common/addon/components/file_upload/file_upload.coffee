import ember    from 'ember'
import base     from 'thinkspace-base/components/base'
import uploader from 'ember-uploader'

export default base.extend
  # # Properties
  classNames:        ['test-upload']
  classNameBindings: ['is_dragging:is-dragging']
  url:               null

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
    # TODO: Implement the S3 signing endpoint and ability to upload here.
    # uploader = uploader.S3Uploader.create({signingUrl: '/test'})
    @reset_drag_counter()
    # event.dataTransfer.files has the files in an object with 0..n as the key.
    length = event.dataTransfer.files.length
    files  = new Array
    for i in [0..(length - 1)]
      file = event.dataTransfer.files[i]
      files.pushObject(file)
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

  actions:
    # `files_changed` is called by the input when the browser selects a file OR via this component's drop.
    files_changed: (files) ->
      console.log "files changed callback: ", files