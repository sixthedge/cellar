module Totem; module Core; module Serializers; module SerializerOptions; module Ability

  def ability_key; :ability; end

  # ###
  # ### CONTROLLER - Set Options.
  # ###

  # Per record can? ability for the arg actions.
  # args:    list (scopeable)
  # example: :read, :update, scope: :root
  def ability_actions(*args)
    options = args.extract_options!
    args    = default_ability_actions if args.blank?
    actions = translate_actions(args)
    key     = :ability_actions
    set_option_value(key, actions, options)
    collect_for(ability_key, key, actions: actions)
  end

  # Add pre-set record ability actions.
  # args:    Hash (scopeable)
  # example: read: true, update: false, scope: :root
  def include_ability(*args)
    options = args.extract_options!
    key     = :include_ability
    set_option_value(key, options.except(:scope), options)
    collect_for(ability_key, key, options)
  end

  # Add ability actions from module method(s).
  # args: Hash (not scopeable)
  #       [:module] required - [module] module containing the method
  #       [:method] optional - [symbol] defaults to controller model class name pluralized
  #       [:id]     optional - [string] defaults to demodulized controller model class name pluralized
  #       [:cache]  optional - [true|false] defaults to true when 'serializer_options.cache' used
  # example: module: MyMod, method: :my_index_method
  # can be called multiple times.
  def include_module_ability(*args)
    options = args.extract_options!
    collect_for_module(ability_key, options)
  end

  # Only serialize the abilities e.g. not any records.
  # args: none
  def ability_only; collect_only_for(ability_key); end

  # ###
  # ### SERIALIZER - Get Options.
  # ###

  # Ability actions to include in the 'ability_json_key'.
  def get_ability_actions(serializer)
    evaluate_option_root_first(serializer, :ability_actions)
  end

  def get_include_ability(serializer)
    evaluate_option_root_first(serializer, :include_ability)
  end

  # Ability key name in json.
  def ability_json_key; :abilities; end

  # ###
  # ### Collect Ability Helpers.
  # ###

  def collect_ability_data;  get_collect_data_for(ability_key); end
  def clear_collect_ability; clear_collect_data_for(ability_key); end

  private

  # Default actions when an 'ability_actions' method is called without an actions.
  # Note: If no 'ability_actions' method is called, then abilities are not added to the json.
  def default_ability_actions
    @default_ability_actions ||= (get_default_option(:ability_actions) || :crud)
  end

  def translate_actions(actions)
    expanded_actions = [actions].flatten.compact.map {|a| a.to_sym}
    if expanded_actions.include?(:crud)
      expanded_actions.delete :crud
      expanded_actions |= [:index, :show, :new, :create, :edit, :update, :destroy]
    end
    expanded_actions.uniq
  end

end; end; end; end; end
