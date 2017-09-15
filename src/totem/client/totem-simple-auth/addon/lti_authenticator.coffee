import ember          from 'ember'
import ns             from 'totem/ns'
import config         from 'totem-config/config'
import ajax           from 'totem/ajax'
import util           from 'totem/util'
import totem_scope    from 'totem/scope'
import totem_cache    from 'totem/cache'
import totem_messages from 'totem-messages/messages'
import base           from 'totem-simple-auth/authenticator'

# ### TODO: Fix for using the cookie store ###

export default base.extend

  authenticate: (data) -> @restore(data)