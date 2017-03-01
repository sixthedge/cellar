import ember from 'ember'
import ns    from 'totem/ns'

export default ember.Mixin.create
  ##### Public
  tw_sync: ->
    @_tw_initialize()
    new ember.RSVP.Promise (resolve, reject) =>
      @_tw_get_nested_promise(@_tw_sync_promise).then =>  # ensure the last embed promise is resolved before returning
        console.log "[tw_sync] Final resolve being called." if @_tw_is_debug()
        resolve()

  tw_edit: ->
    @_tw_initialize()
    @_tw_set_is_edit()
    new ember.RSVP.Promise (resolve, reject) =>
      @_tw_get_nested_promise(@_tw_edit_promise).then =>  # ensure the last embed promise is resolved before returning
        console.log "[tw_edit] Final resolve being called." if @_tw_is_debug()
        resolve()

  ##### Private
  _tw_sync_promise: (data, options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      console.log "[_tw_sync_promise] data, options: ", data, options if @_tw_is_debug()
      instructions = data.mapped_instructions
      ember.RSVP.hash(data.promises).then (results) =>
        for key of results
          instruction = instructions.findBy('to', key)
          console.log "[_tw_sync_promise] Instruction of: ", instruction if @_tw_is_debug()
          instruction.set('resolved_promise', results[key])

        instructions.forEach (instruction) =>
          console.log "[_tw_sync_promise] Parsing instruction of: ", instruction if @_tw_is_debug()

          is_promise       = instruction.get('is_promise')
          resolved_promise = instruction.get('resolved_promise')
          on_obj           = instruction.get('on_obj')
          to               = instruction.get('to')
          polymorphic      = instruction.get('polymorphic')
          prop             = instruction.get('prop')
          prop_obj         = instruction.get('prop_obj')
          prop_objs        = ember.makeArray(prop_obj)

          console.log "[_tw_sync_promise] To value to be set [#{to}] on: ", on_obj if @_tw_is_debug()
          # Pushing onto a resolved promise (e.g. association)
          if ember.isPresent(to) # Ignore instructions without a `to` option.
            if is_promise and ember.isArray(resolved_promise)
              resolved_promise.clear()
              prop_objs.forEach (obj) =>
                @_tw_push_unless_contains(resolved_promise, obj)
            else
              if polymorphic
                console.error "[_tw_sync_promise] Cannot set a polymorphic that doesn't exist: [#{prop_obj}] for instruction: ", instruction unless ember.isPresent(prop_obj)
                id   = "#{to}_id"
                type = "#{to}_type"
                console.log "[_tw_sync_promise] Setting polymorphic of: ", to if @_tw_is_debug()
                on_obj.set(id, prop_obj.get('id'))
                on_obj.set(type, @totem_scope.get_record_path(prop_obj))
              else
                on_obj.set(to, prop_obj)

        ember.RSVP.all(@_tw_map_promise_definitions(data.promise_all)).then =>
          resolve()

  _tw_edit_promise: (data, options) ->
    new ember.RSVP.Promise (resolve, reject) =>
      console.log "[_tw_edit_promise] data, options: ", data, options if @_tw_is_debug()
      instructions = data.mapped_instructions
      promises     = data.promises

      ember.RSVP.hash(promises).then (results) =>
        for key of results
          instruction = instructions.findBy('to', key)
          console.log "[_tw_edit_promise] Instruction for [#{key}]: ", instruction if @_tw_is_debug()
          instruction.set('resolved_promise', results[key])

        instructions.forEach (instruction) =>
          prop    = instruction.get('prop')
          on_prop = instruction.get('on')
          console.log "[_tw_edit_promise] Parsing prop: [#{prop}]", instruction if @_tw_is_debug()
          if ember.isPresent(prop) and ember.isPresent(on_prop)
            value = @_tw_get_instruction_prop_value(instruction)
            console.log "[_tw_edit_promise] Value found as for prop [#{prop}]: ", value if @_tw_is_debug()
            @set(prop, value)
        resolve()

  _tw_get_instruction_prop_value: (instruction) ->
    prop = instruction.get('prop')
    return null unless ember.isPresent(prop)
    single   = instruction.get('single')
    generate = instruction.get('generate')
    to       = instruction.get('to')

    if instruction.get('is_promise')
      value = instruction.get('resolved_promise')
      console.log "[_tw_get_instruction_prop_value] Setting on prop, value PROMISE: ", prop, value if @_tw_is_debug()
    else
      value = instruction.get("on_obj.#{to}")
      console.log "[_tw_get_instruction_prop_value] Setting on prop, value: ", prop, value if @_tw_is_debug()

    # Clone to prevent duplication/modification of relationship arrays.
    if ember.isArray(value)
      values       = ember.makeArray(value)
      values_clone = []
      values.forEach (value) =>
        values_clone.pushObject(value)
      if single then value = values_clone.get('firstObject') else value = values_clone

    # If no record is present and generate is true, create a new instance of the record.
    if generate and not ember.isPresent(value)
      model_type = ember.Inflector.inflector.singularize(to)
      new_obj    = @store.createRecord(model_type)
      value      = new_obj
      console.log "[_tw_get_instruction_prop_value] Generating record of and type: ", new_obj, model_type if @_tw_is_debug()

    console.log "[_tw_get_instruction_prop_value] VALUE found as for [#{prop}]: ", value if @_tw_is_debug()
    value

  _tw_generate_record: (instruction, value) ->
    generate = instruction.get('generate')

    if generate and not ember.isPresent(prop_obj)
      model_type = ember.Inflector.inflector.singularize(to)
      new_obj    = @store.createRecord(model_type)
      console.log "[_tw_instruction_map] Generating record of and type: ", new_obj, model_type if @_tw_is_debug()
      instruction.set('prop_obj', new_obj)


  _tw_get_nested_promise: (map_fn) ->
    new ember.RSVP.Promise (resolve, reject) =>
      data  = @_tw_parse_instructions()
      tasks = data.map => map_fn
      resolve(tasks.reduce (cur, next, i) =>
        return cur.then =>
          return next.call(@, data[i])
      , ember.RSVP.resolve())

  _tw_map_promise_definitions: (definitions) ->
    definitions.map (definition) =>
      fn = definition.get('fn')
      fn.call(@, definition)

  _tw_before_save_promises: (definition) ->
    record      = definition.get('record')
    instruction = definition.get('instruction')
    options     = @_tw_get_options()
    fn_names    = ember.makeArray(instruction.before_save)
    fns         = fn_names.map (name) => 
      fn = options.functions[name]
      console.error "[_tw_before_save_promises] Cannot call before_save on undefined function of [#{name}]" unless ember.isPresent(fn)
      fn.call(@, record)
    console.log "[_tw_before_save_promises] Returning promises of: ", fns if @_tw_is_debug()
    fns

  _tw_after_save_promises: (definition) ->
    record      = definition.get('record')
    instruction = definition.get('instruction')
    options     = @_tw_get_options()
    fn_names    = ember.makeArray(instruction.after_save)
    fns         = fn_names.map (name) => 
      fn = options.functions[name]
      console.error "[_tw_after_save_promises] Cannot call after_save on undefined function of [#{name}]" unless ember.isPresent(fn)
      fn.call(@, record)
    console.log "[_tw_after_save_promises] Returning promises of: ", fns if @_tw_is_debug()
    fns

  _tw_save: (definition) ->
    record      = definition.get('record')
    instruction = definition.get('instruction')
    options     = @_tw_get_options()

    new ember.RSVP.Promise (resolve, reject) =>
      ember.RSVP.all(@_tw_before_save_promises(definition)).then =>
        record.save().then (saved_record) =>
          console.log "[_tw_save] tw saved record: ", saved_record if @_tw_is_debug()
          global_data = options.data
          data        = instruction.get('data')
          if ember.isPresent(data) and ember.isPresent(data.set)
            if ember.isArray(global_data)
              console.log "[_tw_save] Adding object to data (pushObject) of key [#{data.set}]" if @_tw_is_debug()
              global_data.pushObject(saved_record)
            else
              console.log "[_tw_save] Adding object to data (single) of key [#{data.set}]" if @_tw_is_debug()
              global_data[data.set] = saved_record
          ember.RSVP.all(@_tw_after_save_promises(definition)).then =>
            resolve()

  _tw_prop_fn: (definition) ->
    record        = definition.get('record')
    instruction   = definition.get('instruction')
    options       = @_tw_get_options()
    prop_fn_names = instruction.get('prop_fns')
    promises      = []
    return unless ember.isPresent(prop_fn_names)

    new ember.RSVP.Promise (resolve, reject) =>
      prop_fn_names.forEach (name) => 
        fn = options.functions[name]
        console.error "[_tw_prop_fn] Cannot call prop_fn on undefined function of [#{name}]" unless ember.isPresent(fn)
        promises.pushObject(fn.call(@, record))
      ember.RSVP.all(promises).then =>
        resolve()

  _tw_instruction_map: (instruction, group_data) ->
    console.log '[_tw_instruction_map] Instruction mapping, firing gettings: ', instruction if @_tw_is_debug()
    promise_all      = group_data.get('promise_all')
    on_prop          = instruction.get('on')
    prop             = instruction.get('prop')
    save             = instruction.get('save')     or false
    use_ns           = instruction.get('use_ns')   or false
    generate         = instruction.get('generate') or false
    to               = instruction.get('to')
    prop_fns         = instruction.get('prop_fns')
    prop_fns_present = ember.isPresent(prop_fns)
    to               = ns.to_p(to)    if use_ns and not instruction.get('is_mapped')
    prop_obj         = @get(prop)     if ember.isPresent(prop)
    prop_objs        = ember.makeArray(prop_obj) if ember.isPresent(prop_obj)
    on_obj           = @get(on_prop)  if ember.isPresent(on_prop)
    console.log "[_tw_instruction_map] on_obj found as: ", on_obj if @_tw_is_debug()
    on_obj_promise    = on_obj.get(to) if ember.isPresent(to) and ember.isPresent(on_obj)
    console.log "[_tw_instruction_map] on_obj [#{to}] found as: ", on_obj_promise if @_tw_is_debug()
    on_obj_is_promise = not ember.isNone(on_obj_promise) and on_obj_promise.then?
    console.log "[_tw_instruction_map] on_obj_is_promise for [#{to}] on: ", on_obj, on_obj_is_promise if @_tw_is_debug()

    instruction.set('to',             to)
    instruction.set('prop_obj',       prop_obj)
    instruction.set('on_obj',         on_obj)
    instruction.set('on_obj_promise', on_obj_promise)
    instruction.set('is_promise',     on_obj_is_promise)
    instruction.set('is_mapped',      true)
    instruction.set('save',           save)
    instruction.set('use_ns',         use_ns)
    instruction.set('generate',       generate)

    # Add the the RSVP.hash call if there is a promise for the instruction.
    if on_obj_is_promise
      promises     = group_data.get('promises')
      promises[to] = on_obj_promise

    # If a model(s) is to be saved from a given property.
    if ember.isPresent(prop_obj) and save
      prop_objs.forEach (obj) =>
        if obj.get('isDirty')
          console.log "[_tw_instruction_map] Saving value of: ", obj
          definition = ember.Object.create record: obj, instruction: instruction, fn: @_tw_save
          @_tw_push_unless_contains(promise_all, definition)

    # If a model(s) is to be saved and not being set to a controller property.
    # => e.g. save a model and set a global value
    if ember.isPresent(on_obj) and save and not ember.isPresent(prop)
      definition = ember.Object.create record: on_obj, instruction: instruction, fn: @_tw_save
      @_tw_push_unless_contains(promise_all, definition)

    # Functions to be called on the prop_obj(s) - different than before/after_save since it may call save within itself.
    if prop_fns_present and ember.isPresent(prop_obj)
      prop_objs.forEach (obj) =>
        definition = ember.Object.create record: obj, instruction: instruction, fn: @_tw_prop_fn
        @_tw_push_unless_contains(promise_all, definition)

    instruction

  _tw_initialize: ->
    return if @_tw_is_initialized()
    options      = @get('tw_options')
    options.instructions.forEach (group, index) =>
      instructions = []
      group.forEach (raw_instruction) =>
        instruction = ember.Object.create()
        for key of raw_instruction
          instruction.set(key, raw_instruction[key])
        instructions.pushObject(instruction)
      options.instructions[index] = instructions
    @_tw_set_is_initialized()
    @_tw_set_is_not_edit()
    @set('tw_options', options)

  _tw_get_new_group_data: ->
    ember.Object.create
      mapped_instructions: []
      promise_all:         []
      promises:            {}

  _tw_parse_group_data: (group) ->
      group_data          = @_tw_get_new_group_data()
      mapped_instructions = group_data.get('mapped_instructions')
      group.forEach (instruction) =>
        mapped_instruction = @_tw_instruction_map(instruction, group_data)
        mapped_instructions.pushObject(mapped_instruction)
      group_data

  _tw_parse_instructions: ->
      options      = @_tw_get_options()
      instructions = @_tw_get_instructions()
      options.data = {}
      data         = []
      instructions.forEach (group) =>
        group_data = @_tw_parse_group_data(group)
        data.pushObject(group_data)
      data

  _tw_push_unless_contains: (array, values) ->
    values = ember.makeArray(values)
    return if ember.isEmpty(values)
    values.forEach (value) =>
      array.pushObject(value) unless array.includes(value) or ember.isBlank(value) 

  _tw_is_initialized: ->
    @get('tw_options.is_initialized')

  _tw_set_is_initialized: ->
    @set('tw_options.is_initialized', true)

  _tw_is_edit: ->
    @get('tw_options.is_edit')

  _tw_set_is_edit: ->
    @set('tw_options.is_edit', true)

  _tw_set_is_not_edit: ->
    @set('tw_options.is_edit', false)
    
  _tw_get_options: ->
    @get('tw_options')

  _tw_get_global_data: ->
    @get('tw_options.data')

  _tw_get_instructions: ->
    @get('tw_options.instructions')

  _tw_is_debug: ->
    @get('tw_options.debug')