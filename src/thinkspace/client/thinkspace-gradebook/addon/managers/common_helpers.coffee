import ember from 'ember'
import ns    from 'totem/ns'
import ajax  from 'totem/ajax'
import totem_scope    from 'totem/scope'
import totem_messages from 'totem-messages/messages'

export default ember.Object.create

  get_sort_links: (sort_def, sort_order, link_for) ->
    links = []
    for own key, hash of sort_def
      if (link_for == 'all' or hash.for == link_for or hash.for == 'all')
        text    = [hash.heading.column_1, hash.heading.column_2]
        sort_by = hash.heading_sort_by
        text.unshift(sort_by)  if sort_by
        display_text = hash.title or text.compact().join('->')
        links.push {text: display_text, key: key, active: (key == sort_order)}
    links

  # ###
  # ### Update Score.
  # ###

  update_roster_score: (scores, values, score) ->
    new ember.RSVP.Promise (resolve, reject) =>
      state_id     = values.get('state_id')
      score_hashes = scores.filterBy 'state_id', state_id
      return reject()  if ember.isBlank(score_hashes)
      score = Number(score)
      score_hashes.forEach (hash) => hash.set('score', score)
      @update_phase_state_value(values, state_id, 'new_score', score)
      resolve()

  # ###
  # ### Update State.
  # ###

  update_roster_state: (scores, values, state) ->
    new ember.RSVP.Promise (resolve, reject) =>
      state_id     = values.get('state_id')
      score_hashes = scores.filterBy 'state_id', state_id
      return reject()  if ember.isBlank(score_hashes)
      score_hashes.forEach (hash) => hash.set('state', state)
      @update_phase_state_value(values, state_id, 'new_state', state)
      resolve()

  update_phase_state_value: (values, state_id, key, value) ->
    new ember.RSVP.Promise (resolve, reject) =>
      store    = totem_scope.get_store()
      phase_id = values.get('phase_id')
      return reject()  unless phase_id
      @tc.find_record(ns.to_p('phase'), phase_id).then (phase) =>
        return reject()  unless phase
        totem_scope.authable(phase)
        path         = ns.to_p 'phase_state'
        record       = {}
        record[path] = {"#{key}": value}
        query = 
          action:   'roster_update'
          verb:     'put'
          model:    ns.to_p 'phase_state'
          id:       state_id
          data:     record
        ajax.object(query).then =>
          resolve()
        , (error) => reject(error)

  # ###
  # ### Ajax.
  # ###

  get_assignment_roster_from_server: (assignment) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return reject() unless assignment
      query =
        verb:   'post'
        action: 'roster'
        model:  assignment
        id:     assignment.get('id')
        data:   
          auth:
            sub_action: 'assignment_roster'
      totem_messages.show_loading_outlet()
      ajax.object(query).then (roster) =>
        resolve(roster)
      , (error) => reject(error)

  get_phase_roster_from_server: (assignment, phase) ->
    new ember.RSVP.Promise (resolve, reject) =>
      return reject() unless (phase and assignment)
      query =
        verb:   'post'
        action: 'roster'
        model:  assignment
        id:     assignment.get('id')
        data:   
          auth:
            sub_action: 'phase_roster'
            phase_id:   phase.get('id')  
      totem_messages.show_loading_outlet()
      ajax.object(query).then (roster) =>
        resolve(roster)
      , (error) => reject(error)
