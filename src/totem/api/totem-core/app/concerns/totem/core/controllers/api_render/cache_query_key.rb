module Totem; module Core; module Controllers; module ApiRender; module CacheQueryKey
  # ### See usage documentation at bottom of this file.
  # ###
  # ### Query Cache Key Parts.
  # ###

  def controller_cache_query_key(record_or_scope, options)
    parts = Array.new
    array = [serializer_options.cache_query].flatten.compact
    return parts if array.blank?
    var = serializer_options.cache_instance_var
    ros = var.blank? ? record_or_scope : controller_cache_query_key_get_instance_variable(var)
    array.each do |hash|
      raise_controller_cache_error "Cache key query must be an array of hashes not #{hash.inspect}."  unless hash.is_a?(Hash)
      name = hash[:name]
      parts.push(name)  if name.present?
      part = controller_cache_query_key_apply_hash_method(ros, hash)
      parts.push part.present? ? part : :none
    end
    parts
  end

  def controller_cache_query_key_get_instance_variable(var)
    var = "@#{var}"  unless var.to_s.start_with?('@')
    val = self.instance_variable_get(var.to_sym)
    raise_controller_cache_error "Cache key query :instance_var #{var.inspect} is blank."  if val.blank?
    val
  end

  def controller_cache_query_key_apply_hash_method(record_or_scope, hash)
    if controller_cache_record_or_scope_is_a_scope?(record_or_scope)
      controller_cache_query_key_get_value_for_scope(record_or_scope.dup, hash)
    else
      controller_cache_query_key_get_value_for_record(record_or_scope, hash)
    end
  end

  # ###
  # ### Scope.
  # ###

  def controller_cache_query_key_get_value_for_scope(scope, hash)
    method      = controller_cache_query_key_get_hash_method(hash)
    association = hash[method]
    scope       = scope.joins(association) if association.present?
    controller_cache_query_key_get_scope_value(scope, method, hash)
  end

  # ###
  # ### Record.
  # ###

  def controller_cache_query_key_get_value_for_record(record, hash)
    method      = controller_cache_query_key_get_hash_method(hash)
    association = hash[method]
    column      = controller_cache_query_key_get_hash_column(method, hash)
    case
    when association.present?
      record_or_scope = controller_cache_query_key_get_value(record, association)
      return nil unless record_or_scope.present?
      if controller_cache_record_or_scope_is_a_scope?(record_or_scope)
        controller_cache_query_key_get_scope_value(record_or_scope, method, hash)
      else
        controller_cache_query_key_get_value(record_or_scope, column)
      end
    when controller_cache_query_key_get_hash_scope(hash).present?
      controller_cache_query_key_get_scope_value(record, method, hash)
    else
      controller_cache_query_key_get_value(record, column)
    end
  end

  # ###
  # ### Helpers.
  # ###

  def controller_cache_query_key_get_value(record_or_scope, method, arg=nil)
    controller_cache_query_key_method_error(record_or_scope, method, arg) unless record_or_scope.respond_to?(method)
    arg.blank? ? record_or_scope.send(method) : record_or_scope.send(method, arg)
  end

  # The 'scope' can be a record if the first hash[:scope] creates a scope from the record.
  def controller_cache_query_key_get_scope_value(scope, method, hash)
    scope      = controller_cache_query_key_apply_hash_scopes(scope, hash)
    scope, arg = controller_cache_query_key_apply_additional_scopes(scope, method, hash)
    value = controller_cache_query_key_get_value(scope, method, arg)
    value = value.uniq  if hash[:unique].present? && value.is_a?(Array)
    controller_cache_query_key_debug(scope, method, hash, arg, value)  if hash[:debug].present?
    value
  end

  def controller_cache_query_key_apply_hash_scopes(scope, hash)
    where  = hash[:where]
    scope  = scope.where(where) if where.present?
    if (scopes = controller_cache_query_key_get_hash_scope(hash)).present?
      args = hash[:scope_args]
      args = args.blank? ? [] : Array(args).dup
      [scopes].flatten.compact.each do |hash_scope|
        hash_args = args.shift
        controller_cache_query_key_method_error(scope, hash_scope, hash_args) unless scope.respond_to?(hash_scope)
        scope = controller_cache_query_key_get_value(scope, hash_scope, hash_args)
      end
    end
    scope
  end

  def controller_cache_query_key_apply_additional_scopes(scope, method, hash)
    association = hash[method]
    column      = controller_cache_query_key_get_hash_column(method, hash)
    table       = hash[:table]
    table       = association.to_s.pluralize  if table.blank? && association.present?
    if association.blank? && table.blank?
      scope = scope.order(column)  if method == :pluck && column.present?
      return [scope, column]
    end
    if (distinct_column = hash[:distinct]).present?
      arg   = nil
      col   = "#{table}.#{distinct_column}"
      scope = scope.select("distinct #{col}")
    else
      col = column.blank? ? nil : "#{table}.#{column}"
      arg = col.blank? ? table : col
    end
    scope = scope.order(col)  if method == :pluck && col.present? 
    [scope, arg]
  end

  def controller_cache_query_key_get_hash_scope(hash); hash[:scope]; end

  def controller_cache_query_key_get_hash_column(method, hash)
    column = hash[:column]
    column = :updated_at  if column.blank? && method != :count
    column
  end

  def controller_cache_query_key_get_hash_method(hash)
    case
    when hash.has_key?(:method)       then hash[:method]
    when hash.has_key?(:count)        then :count
    when hash.has_key?(:maximum)      then :maximum
    when hash.has_key?(:minimum)      then :minimum
    when hash.has_key?(:pluck)        then :pluck
    else :maximum
    end
  end

  def controller_cache_query_key_debug(scope, method, hash, arg, value)
    puts "\n"
    val    = value.is_a?(Time) ? value.utc.to_s(:nsec) : value.to_s
    column = controller_cache_query_key_get_hash_column(method, hash)
    controller_debug_message ('-' * 100)
    controller_debug_message "Controller : #{self.class.name}##{self.action_name}"
    controller_debug_message "Method     : #{method.inspect}"
    controller_debug_message "Column     : #{column.inspect}"
    # controller_debug_message "Hash       : #{hash.inspect}"
    controller_debug_message "Arg        : #{method}(#{arg})"
    controller_debug_message "Sql        : #{scope.to_sql}"
    controller_debug_message "Value      : #{val.inspect}"
    controller_debug_message ('-' * 100)
    puts "\n"
  end

  def controller_cache_query_key_method_error(record_or_scope, method, arg=nil)
    if controller_cache_record_or_scope_is_a_scope?(record_or_scope)
      type    = 'Scope'
      object  = record_or_scope.first.class.name
    else
      type   = 'Record'
      object = record_or_scope
    end
    message = "\n"
    message += "  Does not respond to method #{method.inspect} ->\n"
    message += "    #{type}: #{object.inspect}\n"
    message += "    Params: #{arg.inspect}\n"  if arg.present?
    raise_controller_cache_error(message)
  end

end; end; end; end; end

# Implements basic cache query-key functionality in the serializer options e.g. minimum, maximum, count, pluck.
#
# Allows using the same cache query-key hash for scopes and a single record.
# Values must be symbols ("where" scope values can contain strings).
#
# Cache query keys can be generated via a model method (class/instance) 'totem_cache_query_key_{action-name}'
# or via the serializer options using this module.
#
# Serializer Options Cache Key: 
#   name:            [String|Symbol] string/ before the value
#   method:          [:minimum|:maximum|:count|:pluck] default :maximum; sql method to use to get the value
#   scope:           [Symbol|Arrry(Symbols)] scopes to be applied
#   scope_args:      [Array] positionally passed as parameters to the scope
#   minimum:         [Symbol] association name (sets the method to :minimum)
#   maximum:         [Symbol] association name (sets the method to :maximum)
#   count:           [Symbol] association name (sets the method to :count)
#   pluck:           [Symbol] association name (sets the method to :pluck)
#   column:          [Symbol] defaults :updated_at; column to be evaluated by the method
#   table:           [Symbol] table name for the method value (overrides the association name)
#   where:           where-clause for a scope (used as-is); e.g. scope.where(where-clause)
#:                   - record: applied after a record association
#:                   - scope:  after joins(:association-name) but before additional scopes (e.g. before scope: :active)
#   debug:           [true|false] default false; print sql info for scopes
#   model_query_key: [true|false] default false; adds the model method query keys to the serializer options query keys
#   distinct:        [true|false] default false; if true 'select distinct' add to sql query
#   unique:          [true|false] default false; if true and value is an array, returns unique values
#:                   - unique is done after value array from sql query so should only be used when query returns a small number of values.
#
# Complex query keys should be performed in a model scope.
# If want to add the model query keys to the serializer options query keys use the cache option: 'model_query_key: true'.
#   - e.g. serialzer_options.cache model_query_key: true
#
# Method and column values default to the common use case for record(s): method=:maximum, column=:updated_at.
# To override the default method add a 'method' option e.g. name: spaces_min, method: :minimum).
#
# Cache query key value hash(s) can be set by the serializer_options 'cache' method or 'cache_query_key' method (note: values are additive).
# The 'cache_query_key' method can be called multiple times to add query key values.
# The value can be a single hash or an array of hashes.
#   - serializer_options.cache query_key: {}          e.g. serializer_options.cache query_key: {name: :spaces}
#   - serializer_options.cache query_key: [{}, {}]    e.g. serializer_options.cache query_key: [{name: :spaces}, {name: :other}, ...]
#   - serializer_options.cache_query {}               e.g. serializer_options.cache_query_key name: :spaces
#   - serializer_options.cache_query [{}, {}]         e.g. serializer_options.cache_query_key [{name: :spaces}, {name: :other}, ...]
#
# The methods minimum, maximum, count and pluck can be used with a record or scope.
# The methods value must be an association name (e.g. maximum: :thinkspace_common_users).
# A 'scope' option (single value or array of values) can be applied to the record or scope before getting the query key value.
#
# If the scope(s) include 'joins' to other tables, the 'table' option ensures the value is from the correct table.
# By default, when the query key contains an  association, the association name (pluralized) is used as the table name.
#
# When required, 'scope_args' can be supplied and are passed positionally to the scope (if not nil).
#   - scope:      [scope1, scope2_by_ownerable],
#     scope_args: [nil, ownerable]
#     table:      :scope2_table_name
# The table name will be prepended to the column e.g. maximum('thinkspace_common_users.updated_at').
#
# If the serialized record-or-scope is not what the query key should be based, add the cache option 'instance_var'.
# Set this option to the instance variable name e.g. serializer_options.cache instance_var: :myspace (uses @myspace).
# Be sure to set this instance variable in the controller if it does not already exist (e.g. not set by CanCan).
#
# Examples 'serializer_options.cache query_key: {}' hash (assumes serializing a space record or a space records scope).
#   query_key: [
#     => maximum(:updated_at) note: method will default to :maximum and column will default to :updated_at
#       {name: :spaces},
#     => maximum(:updated_at) (same as above)
#       {name: :spaces, column: :updated_at},
#     => spaces-space_users maximum(:updated_at)
#       {name: :space_users, maximum: :thinkspace_common_space_users},
#     => space-assignments maximum(:release_at) where release_at > now
#       {name: :release_at,  maximum: :thinkspace_casespace_assignments, where: ['thinkspace_casespace_assignments.release_at < ?', Time.now], column: :release_at},
#     => spaces maximum(:updated_at) for only active spaces
#       {name: :active_spaces, scope: :scope_active},
#     => space ids (e.g. space_ids/[1,2,3])
#       {name: :spaces_ids, method: :pluck, column: :id},
#     => active space ids (e.g. space_ids/[2,3])
#       {name: :active_spaces_ids, method: :pluck, column: :id, scope: :scope_active},
#     => spaces count (e.g. spaces_count/2)
#       {name: :spaces_count, method: :count},
#     => distinct spaces-space_users user_ids count (e.g. space_users_count/5)
#       {name: :space_users_count, count: :thinkspace_common_space_users, distinct: :user_id},
#     => unique spaces-space_users roles (e.g. space_users_count/['read', 'update']) (not very practical example)
#       {name: :space_user_roles, pluck: :thinkspace_common_space_users, column: :role, unique: true},
#   'distinct' is different than 'unique'.  Unique only applies to an array of values (e.g. plucked values) and
#    is performed after the query on the returned values.  Distinct is part of the sql query.
