import ember from 'ember'
import ta    from 'totem/ds/associations'

export default ta.Model.extend ta.add(
    ta.belongs_to 'library', reads: {}
  ),
  # Similar to a normal Comment, but acts as a template.
  # When adding a comment from the library, it will copy its `comment`.
  comment:    ta.attr('string')
  user_id:    ta.attr('number')
  uses:       ta.attr('number')
  last_used:  ta.attr('date')
  created_at: ta.attr('date')
  all_tags:   ta.attr()

  increment_uses: (count=1) ->
    uses = @get 'uses'
    @set 'uses', uses + count
    @save()