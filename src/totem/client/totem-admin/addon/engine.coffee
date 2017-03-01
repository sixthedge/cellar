import env           from './config/environment'
import totem_engines from 'totem-engines/engines'

export default new totem_engines(env).get_engine()
