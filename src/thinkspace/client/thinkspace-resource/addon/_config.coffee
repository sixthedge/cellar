import env from './config/environment'

export default {

  env: env

  ns:
    namespaces: {resource: 'thinkspace/resource'}
    type_to_namespace:
      resourceable: 'resource'
      file:         'resource'
      link:         'resource'
      tag:          'resource'

}
