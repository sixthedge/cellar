import ember from 'ember'
import base  from 'totem/mixins/data/base_module'

export default base.extend

  add: (abilities) ->
    unless @is_object(abilities)
      console.error "Must pass a 'key: value' object to #{@mod_name}.add() not:", abilities
      return
    @convert_to_boolean_abilities(abilities)
    ember.merge @added_abilities, abilities

  # ###
  # ### Private.
  # ###

  init_values: (source) ->
    @_super(source)
    @added_abilities = {}
    @totem_data.set_source_property('can')
    @totem_data.set_source_property('cannot')
    @set_data()

  set_data: ->
    new ember.RSVP.Promise (resolve, reject) =>
      return resolve()  unless @process_source_data()
      @get_ability().then (abilities) =>
        @get_source().setProperties
          can:    abilities.can
          cannot: abilities.cannot
        resolve()

  get_ability: ->
    new ember.RSVP.Promise (resolve, reject) =>
      @get_data().then (abilities) =>
        abilities = {} if ember.isBlank(abilities)
        ember.merge abilities, @added_abilities
        ab = @get_can_and_cannot_abilities(abilities)
        @call_source_callback(ab).then =>
          resolve(ab)

  # ###
  # ### Abilities.
  # ###

  get_can_and_cannot_abilities: (abilities) ->
    @add_model_abilities(abilities)
    @add_missing_abilities(abilities)
    @convert_to_boolean(abilities)
    can    = abilities
    cannot = @get_inverse_abilities(abilities)
    {can: can, cannot: cannot}

  # Allow some backward compatibility for models that still have an 'abilities' attribute.
  add_model_abilities: (abilities) ->
    model = @get_source_model()
    return unless @is_record(model)
    model_abilities = model.get('abilities')
    return unless @is_object(model_abilities)
    keys = @get_object_keys(model_abilities)
    keys.map (key) -> abilities[key] = model_abilities[key]  unless ember.isPresent(abilities[key])

  # Default the crud abilities when not included.
  add_missing_abilities: (abilities) ->
    update            = abilities.update or false
    abilities.update  = update
    abilities.create  = update  unless ember.isPresent(abilities.create)
    abilities.destroy = update  unless ember.isPresent(abilities.destroy)

  # ###
  # ### Print.
  # ###

  print_ability: (options={}) ->
    can    = options.can
    can    = true unless ember.isPresent(can)
    cannot = options.cannot
    if can
      @print_header()
      console.info 'CAN ->'
      @print_data @get('can')
    if cannot
      @print_header() unless can
      console.info 'CANNOT ->'
      @print_data @get('cannot')
