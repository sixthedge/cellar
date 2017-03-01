import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.has_many 'library_comments', reads: {name: 'comments'}
  ),

  user_id:  ta.attr('number')
  all_tags: ta.attr()

  