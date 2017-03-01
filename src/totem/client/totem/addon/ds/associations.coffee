import ember from 'ember'
import ds    from 'ember-data'
import ns    from 'totem/ns'
import totem_error      from 'totem/error'
import totem_data_mixin from 'totem/mixins/data'

class TotemAssociations

  @totem_data: totem_data_mixin

  @Model: ds.Model.extend
    toString: -> "#{@constructor.modelName}:#{@get('id')}:#{ember.guidFor(@)}"

  @attr: (type, options) -> ds.attr(type, options)

  @PromiseArray:  ds.PromiseArray
  @PromiseObject: ds.PromiseObject

  @to_p:    -> ns.to_p(arguments)
  @to_o:    -> ns.to_o(arguments)
  @to_t:    -> ns.to_t(arguments)
  @to_prop: -> ns.to_prop(arguments)

  @add: ->
    result = {}
    ember.merge(result, association) for association in arguments
    ember.Mixin.create(result)

  @belongs_to: (type, options={}) ->
    type = TotemAssociations.to_p(type) unless options.ns == false
    TotemAssociations.association_defaults(options)
    assoc = options.type or type
    delete options.type
    result = {}
    TotemAssociations.include_notify_observable(result, assoc, options)
    TotemAssociations.include_reads(result, assoc, options)
    delete options.belongs_to
    result[type] = ds.belongsTo(assoc, options)
    result

  @has_many: (type, options={}) ->
    type = TotemAssociations.to_p(type) unless options.ns == false
    TotemAssociations.association_defaults(options)
    assoc = options.type or type.pluralize()
    delete options.type
    result = {}
    TotemAssociations.include_notify_observable(result, assoc, options)
    TotemAssociations.include_reads(result, assoc, options)
    delete options.has_many
    result[assoc] = ds.hasMany(type.singularize(), options)  # singularize the type path
    result

  @polymorphic: (name, options={}) ->
    result = {}
    totem_error.throw @, "A totem_polymorphic requires a string name as the first parameter."  unless name and typeof(name) == 'string'
    attribute    = options.attribute or name
    result[name] = ember.computed -> (new TotemAssociationsPolymorphic(attribute)).call(@)
    result

  # Returns a live 'store.filter' of record type 'ta.to_p(name).singularize()'.
  # Store records are filtered based on the record id matching the filtered record-attribute specified by 'options.on'.
  # Other options:
  #  polymorphic: true #=> filter on id and type (default false)
  #  model:       property to get the model (if not specified uses @; e.g. mixin is in a model)
  #  load:        computed property(s) to 'get' before filtering (can be an array of property names) (default none)
  #:              must return a promise
  # See the TotemAssociationStoreFilter below for more options.
  @store_filter: (name, options={}) ->
    totem_error.throw @, "A totem_associations store filter 'on' is blank."  unless options.on
    if options.reads
      totem_error.throw @, "A totem_associations store 'reads' must contain a name."  unless options.reads.name
      totem_error.throw @, "A totem_associations store 'reads' name must be different than the store name."  if name == options.reads.name
    type = TotemAssociations.to_p(name).singularize()
    result = {}
    TotemAssociations.include_notify_observable(result, name, options)
    TotemAssociations.include_reads(result, name, options)
    result[name] = ember.computed -> (new TotemAssociationsStoreFilter(name, type, options)).call(@)
    result

  @association_defaults: (options) ->
    options.async = true  unless options.async == false

  @include_notify_observable: (result, assoc, options) ->
    return unless options.notify or options.notify_property
    # Notify association on path_ids change.
    if options.notify
      notifies = ember.makeArray(options.notify)
      delete options.notify
      observe_on  = []
      for notify in notifies
        switch notify
          when true
            observe_on.push 'totem_scope.path_ids'
          else
            observe_on.push "totem_scope.path_ids.#{notify}"
      notify_observer = (->
        @notifyPropertyChange(assoc)
      ).observes(observe_on...)
      prop = '_notify_' + assoc
      result[prop] = notify_observer
    # Notfity association on an object property change.
    if options.notify_property
      notify_properties = ember.makeArray(options.notify_property)
      delete options.notify_property
      observe_on = []
      for notify in notify_properties
        observe_on.push notify
      notify_observer = (->
        @notifyPropertyChange(assoc)
      ).observes(observe_on...)
      prop = '_notify_property_' + assoc
      result[prop] = notify_observer

  @include_reads: (result, assoc, options) ->
    return unless options.reads
    reads = ember.makeArray(options.reads)
    delete options.reads
    for opts in reads
      name        = opts.name or assoc.split('/').pop()  # default to last part of association path
      filter      = opts.filter
      filter_fn   = opts.filter_fn
      sort        = opts.sort
      from        = opts.from
      from_notify = opts.notify != false
      totem_error.throw @, "A totem_associations 'reads' object must contain a name."  unless name

      # Setup up an alias when the 'reads' contains a notify to only notify changes for the specific 'reads' name.
      if opts.notify or opts.notify_property
        alias_prop         = "_ta_alias_#{name}_#{assoc}"
        result[alias_prop] = ember.computed.alias assoc
        assoc_prop         = alias_prop
      else
        assoc_prop = assoc

      TotemAssociations.include_notify_observable(result, assoc_prop, opts)  # add any notifications

      # 'From' uses a 'store.filter' to create an array of association records that match the 'from' record's 'id'.
      # This array substitutes for a model association.
      # Note: the association records must have a 'ds.attr' with the 'from' record's id.
      # This is a 'live' array and will be updated whenever a create/delete record is performed.
      # A 'from' defaults to adding a totem_scope id change notification when filtering and notify != false
      # since the 'store.filter' changes are record-by-record.
      if from
        from = TotemAssociations.to_p(from) unless opts.ns == false
        if sort or filter then assoc_prop = '_ta_store_' + name else assoc_prop = name
        result[assoc_prop] = ember.computed -> (new TotemAssociationsFrom(assoc, from, opts.self, opts.id)).call(@)
        return if assoc_prop == name  # already setup the 'name' since no filter or sort and don't need an alias

      if filter
        filter_function = new TotemAssociationsFilter(filter, filter_fn)

      if sort
        sort_on_prop         = '_ta_sort_' + name + '_by'
        sort_prop            = '_ta_sort'
        sort_prop           += '_'  unless assoc_prop.match(/^_/)
        sort_prop           += assoc_prop
        sort_prop           += '_' + name  # make unique when multiple read names
        result[sort_on_prop] = ember.makeArray(sort)

      # ### Add filter and sort to result object ### #

      # filter -> sort
      if filter and sort
        # Have to sort before filtering due to the index issue because ember.computed.sort fires against property changes
        # => This raises an error if the view_user_id is changed within a .then => block.
        result[sort_prop] = ember.computed.sort   assoc_prop, sort_on_prop
        result[name]      = ember.computed.filter sort_prop, filter_function
        TotemAssociations.include_notify_observable(result, sort_prop, notify: true)  if from and from_notify  # notify the filter its source array changed and to re-filter

      # filter
      else if filter
        result[name] = ember.computed.filter assoc_prop, filter_function
        TotemAssociations.include_notify_observable(result, assoc_prop, notify: true) if from and from_notify  # notify the filter its source array changed and to re-filter

      # sort
      else if sort
        result[name] = ember.computed.sort assoc_prop, sort_on_prop

      # alias
      else
        result[name] = ember.computed.alias assoc_prop

  # '@' (e.g. this) is the current model instance.  Therefore, any @func-name() must be available in
  # the instance e.g. @store, @totem_scope, etc.
  # This function uses 'store.find(type, id)'; if the record is not in the store it will query for it.
  class TotemAssociationsPolymorphic
    constructor: (attribute) ->
      return @get_polymorphic_function(attribute)

    get_polymorphic_function: (attribute) ->
      fn = ->
        promise = new ember.RSVP.Promise (resolve, reject) =>
          type = @get("#{attribute}_type")
          id   = @get("#{attribute}_id")
          return resolve(null)  unless (type and id)
          type = @totem_scope.rails_polymorphic_type_to_path(type)
          record = @store.peekRecord(type, id)
          return resolve(record) if record
          @store.findRecord(type, id).then (record) =>
            unless record.get('isDeleted')
              resolve(record)
            else
              resolve(null)
          , (error) =>
            reject(error)
        ds.PromiseObject.create promise: promise

  # '@' (e.g. this) is the current model instance.  Therefore, any @func-name() must be available in
  # the instance e.g. @store, @totem_scope, etc.
  # This function uses 'store.filter' which filters only the 'loaded' records in the store (e.g. no query performed).
  class TotemAssociationsFrom
    constructor: (assoc, from, self, id=null) ->
      return @get_from_function(assoc, from, self, id)

    get_from_function: (assoc, from, self, id) ->
      fn = ->
        promise = new ember.RSVP.Promise (resolve, reject) =>
          id_prop  = id or from.split('/').pop().singularize() + '_id'
          type     = assoc.singularize()
          add_self = self != false and from == @totem_scope.get_record_path(@).pluralize()  # if self and same record type then add instance's id
          @get(from).then (records) =>
            record_ids = records.mapBy 'id'
            if add_self
              id = @get('id')
              record_ids.push id  unless record_ids.includes(id)
            filter_ids     = @totem_scope.make_ids_array record_ids.uniq()
            assoc_promises = records.map (record) => record.get(assoc)
            ember.RSVP.Promise.all(assoc_promises).then =>
              @store.filter(type, (record) =>
                filter_ids.includes record.get(id_prop)
              ).then (filtered_store_records) =>
                resolve(filtered_store_records)
              , (error) =>
                reject(error)
        ds.PromiseArray.create promise: promise

  # Encapsulate the filter so does not reference ds namespace.
  class TotemAssociationsFilter
    constructor: (filter, filter_fn) ->
      return @get_filter_function(filter, filter_fn)

    get_filter_function: (filter, filter_fn) ->
      return filter if typeof filter == 'function'

      switch filter
        when 'users'
          @filter_by_users(filter, filter_fn)
        else
          @filter_by_path(filter, filter_fn)

    filter_by_users: (filter, filter_fn) ->
      if filter_fn
        fn = (record) ->
          return false if filter_fn(record) == false
          @totem_scope.can_view_record_user_id(record)
      else
        fn = (record) ->
          @totem_scope.can_view_record_user_id(record)
      return fn

    filter_by_path: (filter, filter_fn) ->
      if filter_fn
        fn = (record) ->
          return false if filter_fn(record) == false
          @totem_scope.can_view_record_current_path_id(record)
      else
        fn = (record) ->
          @totem_scope.can_view_record_current_path_id(record)
      return fn

  # Return a 'store.filter'.
  class TotemAssociationsStoreFilter
    constructor: (name, type, options) ->
      return @get_store_filter(name, type, options)

    get_store_filter: (name, type, options) ->
      fn = ->

        # ta.store_filter options may contain an additional filtering rule beyond the record id.
        #   filter_on: 'attribute'  #=> string attribute name in the record being filtered
        #   is_blank:  true         #=> the record's attribute-value is blank (uses ember.isBlank)
        #   is_equal:  value        #=> the record's attribute-value == value
        # More may be added in the future e.g. gt, lt, etc.
        __filter_on = (record, options) ->
          filter_attr = options.filter_on
          return true unless filter_attr  # no additional filtering (and record id already passed), so return true
          value = record.get(filter_attr)
          return ember.isBlank(value)         if options.is_blank
          return (value == options.is_equal)  if options.is_equal
          return true

        unless options.destroy == false
          # Destroy the store.filter when the object is destroyed.
          @willDestroy = (->
            @_super()
            filter = @get("#{name}.content")
            return unless filter
            filter.destroy()
          )
        promise = new ember.RSVP.Promise (resolve, reject) =>
          if options.load
            load     = ember.makeArray(options.load)
            promises = load.map (load_prop) => @get(load_prop)
          else
            promises = [ember.RSVP.resolve()]
          model = options.model or @
          if options.model
            model = @get model
          if model.then?
            promises.unshift model
          else
            promises.unshift ember.RSVP.resolve(model)

          ember.RSVP.Promise.all(promises).then (results) =>
            model     = results.get('firstObject')
            filter_id = parseInt model.get('id')
            if options.polymorphic
              id_attr     = options.on + '_id'
              type_attr   = options.on + '_type'
              filter_type = @totem_scope.get_record_path(model)
              @store.filter(type, (record) =>
                record_id   = parseInt record.get(id_attr)
                record_type = @totem_scope.rails_polymorphic_type_to_path(record.get(type_attr))
                console.warn 'filter record', record_id, filter_id, record_type, filter_type, record.toString()
                return false unless (filter_id == record_id and filter_type == record_type)
                __filter_on(record, options)
              ).then (filtered_store_records) =>
                resolve(filtered_store_records)
              , (error) =>
                reject(error)
            else
              id_attr = options.on
              @store.filter(type, (record) =>
                record_id = parseInt record.get(id_attr)
                return false unless filter_id == record_id
                __filter_on(record, options)
              ).then (filtered_store_records) =>
                resolve(filtered_store_records)
              , (error) =>
                reject(error)
          , (error) =>
            reject(error)
        ds.PromiseArray.create promise: promise

export default TotemAssociations
