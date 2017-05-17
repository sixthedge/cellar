import ember  from 'ember'
import config from 'totem-config/config'
import base   from 'thinkspace-user/components/sign_up'

export default base.extend
  privacy_url: config.urls.privacy
  terms_url:   config.urls.terms