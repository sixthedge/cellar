import ember from 'ember'

export default ember.Helper.helper ([current_phase_state, each_phase_state, each_current_state]) ->
  if current_phase_state == each_phase_state
    '<div class="tsi tsi-small tsi-phase-current"></div>'.htmlSafe()
  else
    "<div class='tsi tsi-small tsi-phase-#{each_current_state}'></div>".htmlSafe()
