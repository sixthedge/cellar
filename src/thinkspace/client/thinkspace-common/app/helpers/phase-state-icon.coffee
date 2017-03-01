import ember from 'ember'

export default ember.Helper.helper ([current_state], options) ->
  title     = (options and options.title) or null
  tag_title = (title and "title='#{title}'") or ''
  if current_state
    "<div class='tsi tsi-small tsi-phase-#{current_state}' #{tag_title}></div>".htmlSafe()
  else
    "<div class='tsi tsi-small tsi-phase-unlocked #{tag_title}></div>".htmlSafe()
