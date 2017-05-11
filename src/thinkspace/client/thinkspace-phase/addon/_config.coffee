import env from './config/environment'

export default {

  env: env

  engine:
    mount:           {as: 'phases', path: '/cases/:assignment_id/phases'}
    external_routes: [{login: 'users.sign_in'}, 'spaces.index', 'spaces.show', 'cases.show']

  ns:
    namespaces: {casespace: 'thinkspace/casespace'}
    type_to_namespace:
      phase:           'casespace'
      phase_template:  'casespace'
      phase_component: 'casespace'
      phase_state:     'casespace'
      phase_score:     'casespace'

  query_params:
    phase:         ownerable: true, authable: false
    phase_score:   ownerable: true, authable: true
    phase_state:   ownerable: true, authable: true

  add_engines: [
    'thinkspace-message'
    'thinkspace-dock'
    'thinkspace-artifact'
    'thinkspace-html'
    'thinkspace-diagnostic-path'
    'thinkspace-diagnostic-expert-path'
    'thinkspace-lab-vet-med'
    'thinkspace-observation-list'
    'thinkspace-peer-assessment-pe'
    'thinkspace-readiness-assurance'
    'thinkspace-weather-forecaster'
    'thinkspace-toolbar':      {external_routes: {home: 'spaces.index'}}
    'thinkspace-markup':       {dock: {routes: ['phases.show'], right_pocket: true}}
    'thinkspace-resource':     {dock: {routes: ['phases.show'], right_pocket: true}}
    'thinkspace-peer-review':  {dock: {routes: ['phases.show'], top_pocket: true}}
    'thinkspace-gradebook':    {dock: {routes: ['phases.show'], top_pocket: true}}
  ]
}
