module Totem; module Core; module Serializers; module SerializerOptions; module Authorize

  # ###
  # ### CONTROLLER - Set Options.
  # ###

  # Use the ability 'action' when serializing an association.
  def authorize_action(*args)
    options = args.extract_options!
    action  = args.shift
    args.each do |association_name|
      set_option_hash_values(:authorize_action, association_name, action, options)
    end
  end

  # ###
  # ### SERIALIZER - Get Options.
  # ###

  def get_authorize_action(serializer, association_name)
    action = evaluate_hash_option(serializer, :authorize_action, association_name)
    return nil    if action.present? && action == :none
    return action if action.present?
    # Use the default when 'serializer_options.authorize_action' not performed.
    # The default action can be specified in the framework/platform.config.yml or will default to :read.
    default_authorize_action
  end

  private

  # Default action when an 'authorize_action' method is called without an action.
  def default_authorize_action
    @default_authorize_action ||= (get_default_option(:authorize_action) || :read).to_sym
  end

end; end; end; end; end
