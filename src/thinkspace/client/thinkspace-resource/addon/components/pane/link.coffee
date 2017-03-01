import ember from 'ember'
import util  from 'totem/util'
import base  from 'thinkspace-base/components/base'

export default base.extend

  # Can override the url based on a criteria.
  # Currently if does not start with http, uses default url.

  default_url: 'http://thinkspace.org'

  link_url: ember.computed ->
    url  = @get('model.url') or ''
    url  = @get('default_url') unless util.starts_with(url, 'http')
    url
