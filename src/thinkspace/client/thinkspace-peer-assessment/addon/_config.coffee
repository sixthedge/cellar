import env from './config/environment'

export default {

  env: env

  ns:
    namespaces:
      peer_assessment: 'thinkspace/peer_assessment'
    type_to_namespace:
      assessment:          'peer_assessment'
      assessment_template: 'peer_assessment'
      review:              'peer_assessment'
      progress_report:     'peer_assessment'

  query_params:
    review: ownerable: true, authable: false

  add_engines: [
    'thinkspace-message'
  ]
}
