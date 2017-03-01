import qp from 'totem-config/query_params'

initializer =
  name: 'totem-config-query-params'
  initialize: (instance) -> qp.process(instance)

export default initializer
