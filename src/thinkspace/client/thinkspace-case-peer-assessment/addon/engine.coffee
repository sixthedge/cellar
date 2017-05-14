import config        from './config/environment'
import totem_engines from 'totem-engines/engines'

export default new totem_engines(config).get_engine()
