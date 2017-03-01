import ember from 'ember'

export default ember.Mixin.create
  # ### Properties
  is_filtering: false
  filter_fn:    'filter_results'


  # ### Helpers
  select_filter_record: (key, record) ->
    records = @get key
    unless records.includes(record)
      records.pushObject(record)
      @[@get('filter_fn')]()

  deselect_filter_record: (key, record) ->
    records = @get key
    if records.includes(record)
      records.removeObject(record)
      @[@get('filter_fn')]()

  clear_filter_key: (key, value=[]) -> 
    @set "filter_#{key}", value
    @[@get('filter_fn')]()

  set_is_filtering:   -> @set 'is_filtering', true
  reset_is_filtering: -> @set 'is_filtering', false