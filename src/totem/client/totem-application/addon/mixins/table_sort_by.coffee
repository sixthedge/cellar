import ember from 'ember'
import util  from 'totem/util'

export default ember.Mixin.create 

  sort_ids:        []
  sort_by:         []
  sorted_by:       null
  default_sort_by: []

  display_sorted_by: ember.computed 'sorted_by.[]', -> ((@get('sorted_by') or []).mapBy 'text').join(', ')

  actions:

    sort_by: (sort) ->
      util.error "Sort by value must be a hash." unless util.is_hash(sort)
      sort_id = sort.id
      util.error "Sort has blank id.", sort if ember.isBlank(sort_id)
      sort_ids = @get('sort_ids')
      sort_ids.push(sort_id) unless sort_ids.includes(sort_id)
      @set_sort_by(sort)

    clear_sort: ->
      @set_id_sort_order(id, null) for id in @get('sort_ids')
      @get('sort_ids').clear()
      @get('sort_by').clear()
      @set 'sorted_by', null

    clear_by: (sort) ->
      return unless util.is_hash(sort)
      sort_id = sort.id
      util.error "Clear by sort has blank id.", sort if ember.isBlank(sort_id)
      @set_id_sort_order(sort_id)
      @set 'sort_ids', @get('sort_ids').without(sort.id)
      @set_sort_by()

    default_by: ->
      @send 'clear_sort'
      default_sort_by = @get('default_sort_by')
      return unless ember.isArray(default_sort_by)
      @send('sort_by', sort) for sort in default_sort_by

  init: ->
    @_super(arguments...)
    @sort_ids  = []
    @sort_by   = []
    @sorted_by = null

  set_id_sort_order: (id, so=null) ->
    hash = @find_sort_by_id(id)
    util.error "Sort id '#{id}' not found." unless util.is_hash(hash)
    ember.set(hash, 'order', so)

  set_sort_by: (sort={}) ->
    sort_ids  = @get('sort_ids') or []
    sort_id   = sort.id
    sort_by   = []
    sorted_by = []
    for id in sort_ids
      hash = @find_sort_by_id(id)
      util.error "Sort id '#{id}' not found." unless util.is_hash(hash)
      so = hash.order
      if id == sort_id
        so = if so == 'asc' then 'desc' else 'asc'
      hash_sort = ember.makeArray(hash.sort).compact()
      for each_sort in hash_sort
        sort_by.push(each_sort + ":#{so}")
      sorted_by.push(hash)
      @set_id_sort_order(id, so)
    @set 'sort_by', sort_by
    @set 'sorted_by', sorted_by
    @notifyPropertyChange 'sort_by'

  find_sort_by_id: (id) ->
    for key, hash of @get('sort')
      return hash if hash.id == id
    null

  set_default_sort_by: (sort_ids) ->
    defaults = []
    for sort_id in ember.makeArray(sort_ids).compact()
      sort = @find_sort_by_id(sort_id)
      defaults.push(sort) if sort
    @set 'default_sort_by', defaults
    @send 'default_by'
