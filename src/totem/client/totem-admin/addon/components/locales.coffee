import ember from 'ember'
import base  from 'totem-base/components/base'

export default base.extend
  tagName: ''

  admin: ember.inject.service()

  didInsertElement: -> @get('admin').set_other_header_links_inactvie('locales')
