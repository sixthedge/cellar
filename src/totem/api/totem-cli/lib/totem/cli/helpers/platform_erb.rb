module Totem; module Cli; module Helpers; class PlatformErb

  attr_reader :caller, :caller_methods
  attr_reader :variables

  # Undef any common dot value variable-names that a method is already defined.
  undef_method :test

  def initialize(caller, options={})
    @caller         = caller
    @caller_methods = options[:caller_methods] # true = allow missing method to use a caller method
    valid_variables?(options[:variables])  # set variables and nested dot variables when passed
  end

  def erb_hash(hash, variables)
    return hash unless hash.is_a?(Hash)
    return hash unless valid_variables?(variables)
    content = erb_content(hash.to_yaml)
    YAML.load(content)
  end

  def erb_array(array, variables)
    return array unless array.is_a?(Array)
    return array unless valid_variables?(variables)
    erb_array = Array.new
    array.each do |a|
      a.blank? ? erb_array.push(a) : erb_array.push(erb_content(a))
    end
    erb_array
  end

  def erb_text(text, variables)
    return text unless text.is_a?(String)
    return text unless valid_variables?(variables)
    erb_content(text)
  end

  private

  def valid_variables?(variables)
    return false if variables.blank?
    return false unless variables.is_a?(Hash)
    @variables = variables.with_indifferent_access
    do_dot_variables
    true
  end

  def do_dot_variables
    variables.keys.each do |key|
      vars = variables[key]
      next unless vars.is_a?(Hash)
      variables[key] = self.class.new(caller, variables: vars, caller_methods: caller_methods)
    end
  end

  def caller_methods?; caller_methods == true; end

  def erb_content(content)
    @context ||= instance_eval('binding')
    ERB.new(content, nil, '-').result(@context)
  end

  def method_missing(method, *args)
    case
    when variables.has_key?(method)                    then variables[method]
    when caller_methods? && caller.respond_to?(method) then caller.send(method)
    else invalid_erb_key(method)
    end
  end

  def invalid_erb_key(method)
    value = "---missing-erb-substitution-for--#{method.to_s}---"
    warn "ERB #{method.to_s.inspect} missing a value and set to #{value.inspect}."
    value
  end

  def warn(message='')
    message = "[WARNING] #{message}"
    caller.respond_to?(:say, true) ? caller.say(message, :yellow) : puts(message)
  end

end; end; end; end
