module Totem; module Core; module Serializers; module SerializerOptions; module Attributes

  # ###
  # ### CONTROLLER - Set Options.
  # ###

  # Order of serializer attribute processing:
  #  1. only
  #  2. add
  #  3. except
  # Notes:
  #  - 'only_attributes(:a)' and 'except_attributes(:a)' results in 'no' attributes (unless have add_attributes other than :a).
  #  - 'add_attributes(:a)'  and 'except_attributes(:a)' results in :a removed from the attributes.
  #  - Add attributes are in addition to 'only' attributes.
  #  - Add attributes are added if the record responds to the attribute's method and is not already in the serialized attributes.
  #  - The serializer options attribute methods below can be scoped.

  # Only include attributes in the args.
  def only_attributes(*args)
    options = args.extract_options!
    set_option_value(:only_attributes, args.map{|a| a.to_sym}, options)
  end

  # Do not include attributes in the args.
  def except_attributes(*args)
    options = args.extract_options!
    set_option_value(:except_attributes, args.map{|a| a.to_sym}, options)
  end

  # Add the attributes in the args e.g. when not in the association.yml attributes list.
  def add_attributes(*args)
    options = args.extract_options!
    set_option_value(:add_attributes, args.map{|a| a.to_sym}, options)
  end

  # ###
  # ### SERIALIZER - Get Options.
  # ###

  def get_except_attributes(serializer)
    evaluate_option_root_first(serializer, :except_attributes)
  end

  def get_only_attributes(serializer)
    evaluate_option_root_first(serializer, :only_attributes)
  end

  def get_add_attributes(serializer)
    evaluate_option_root_first(serializer, :add_attributes)
  end

end; end; end; end; end
