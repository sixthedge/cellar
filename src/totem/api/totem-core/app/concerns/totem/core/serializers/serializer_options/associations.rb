module Totem; module Core; module Serializers; module SerializerOptions; module Associations

  # Note: Unless 'removed', the association 'key/id(s)' are always included.

  # ###
  # ### CONTROLLER - Set Options.
  # ###

  # Hard set the association to either nil (belongs to) or an empty array (has many).
  def blank_association(*args)
    set_option_array_values(:blank, *args)
  end

  # ### INCLUDE ### #

  # Include association keys (and their ids) in the json plus side-load the records.
  def include_all(*args) 
    set_option_value(:include_all, true, *args)
  end

  # Include all associations except associations in args and side-load the records.
  def include_all_except(*args) 
    set_option_array_values(:include_all_except, *args)
  end

  # Include specific associations and side-load the records.
  # When the options include a ':authorize_action' key, apply this action to the association as well.
  # When the options include a ':scope_association' key, scope the association as well.
  def include_association(*args)
    options = args.extract_options!
    if (action = options.delete(:authorize_action)).present?
      args.each do |association_name|
        authorize_action(action, association_name, options)
      end
    end
    if options[:scope_association].present?
      args.each do |association_name|
        scope_association(association_name, options)
      end
    end
    set_option_array_values(:include, *args, options)  # include options hash since removed in extract_options!
  end

  # ### REMOVE ### #

  # Remove all associations (even nested associations).
  def remove_all(*args)
    set_option_value(:remove_all, true, *args)
  end

  # Remove all associations except associations in args.
  def remove_all_except(*args)
    set_option_array_values(:remove_all_except, *args)
  end

  # Remove specific associations.
  def remove_association(*args)
    set_option_array_values(:remove, *args)
  end

  # ### SCOPE ### #
  def scope_association(*args); add_association_scope(*args); end

  # ###
  # ### SERIALIZER - Get Options.
  # ###

  def blank_association?(serializer, association_name)
    evaluate_array_option(serializer, association_name, :blank, ends_with: true)
  end

  def include_association?(serializer, association_name)
    evaluate_array_option(serializer, association_name, :include, ends_with: true)
  end

  def remove_association?(serializer, association_name)
    evaluate_array_option(serializer, association_name, :remove, ends_with: true)
  end

  def get_association_scope(serializer, association_name)
    evaluate_hash_option(serializer, :association_scope, association_name)
  end

  private

  # ###
  # ### Scope Association.
  # ###

  def add_association_scope(*args)
    options = args.extract_options!
    if (scope = options[:scope_association]).present?
      scope_options = options.except(:scope_association)
      args.each do |association_name|
        case scope
        when :params_ownerable  # special value to add the controller params ownerable (e.g. a user or team)
          scope_ownerable_association(association_name, scope_options)
        when :ownerables # special value to add all ownerables for a record (e.g. user and all teams for the record)
          scope_association(association_name, scope_options.merge(scope_by_ownerables: [:current_user, :record]))
        else
          scope_association(association_name, scope.merge(scope_options))
        end
      end
    else
      args.each do |association_name|
        association_scope = merge_association_scopes(association_name, options)
        set_option_hash_values(:association_scope, association_name, association_scope, options)
      end
    end
  end

  def scope_ownerable_association(*args)
    options         = args.extract_options!
    totem_authorize = totem_action_authorize
    case
    when totem_authorize.is_view?
      view_ids       = totem_authorize.params_view_ids
      ownerable_type = totem_authorize.params_view_class_name
      ownerable_id   = view_ids.many? ? view_ids : view_ids.first
    else
      ownerable = totem_authorize.params_ownerable
      error "Params ownerable is blank for associations: #{args.inspect}."  if ownerable.blank?
      ownerable_type = ownerable.class.name
      ownerable_id   = ownerable.id
    end
    error "Params ownerable type name is blank for associations: #{args.inspect}."  if ownerable_type.blank?
    error "Params ownerable id is blank for associations: #{args.inspect}."         if ownerable_id.blank?
    options[:where] = {ownerable_type: ownerable_type, ownerable_id: ownerable_id}  # ownerable_id may be a single id or an array of ids
    scope_association(*args, options)
  end

  def merge_association_scopes(association_name, options)
    merged_scope      = Hash.new
    association_scope = options.except(:scope)
    existing_scope    = get_option_hash_for_scope_and_keys(options[:scope], :association_scope, association_name)
    (existing_scope.keys + association_scope.keys).uniq.each do |key|
      merged_scope[key] = existing_scope.has_key?(key) ? existing_scope[key] : []
      merged_scope[key].push(association_scope[key])  if association_scope.has_key?(key)
    end
    merged_scope
  end

end; end; end; end; end
