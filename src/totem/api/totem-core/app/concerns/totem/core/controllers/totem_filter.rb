module Totem
  module Core
    module Controllers
      module TotemFilter

        extend ::ActiveSupport::Concern

        module ClassMethods

          def totem_filter(*args)
            cattr_reader :totem_filter
            options = args.extract_options!
            self.class_variable_set '@@totem_filter', TotemControllerFilter.new(self, options)
            before_method = :before_action
            self.send(before_method, options.slice(:only, :except, :if, :unless)) do |controller|
              totem_filter.before_action_process(controller)
            end
          end

          class TotemControllerFilter
            attr_reader :debug
            attr_reader :filter_methods
            attr_reader :controller_module_name
            attr_reader :controller_resource_name

            def initialize(controller_class, options={})
              @filter_methods             = Hash.new
              @controller_module_name     = controller_class.name.sub('::Api', '::Concerns::Filters').sub(/Controller$/, '')
              @controller_resource_name   = controller_class.name.demodulize.sub(/Controller$/, '').underscore
              @debug                      = options[:debug] == true
              options[:name]              = options[:name] || controller_resource_name
              options[:is_controller]     = true # allow non-controller modules to default to :name if :module_name is blank
              set_options_before_action(options, true)
              add_modules(options)
            end

            # Public method called by the before_action to call the module methods.
            def before_action_process(controller)
              filter_methods.each do |method_name, hash|
                before_method = hash[:before_action]
                next if before_method.blank?
                action        = controller.action_name
                # before_method = before_method.to_s.gsub('[action]', action)
                before_method = :process_params_filters
                inst          = hash[:instance]
                raise_error "Module #{method_name.inspect} instance is blank." if inst.blank?
                raise_error "Module #{method_name.inspect} does not respond to #{before_method.inspect}." unless inst.respond_to?(before_method)
                totem_debug_message "before filter calling '#{method_name}##{before_method}'"  if debug?
                args = controller_args(controller)
                if has_filters?(args)
                  inst.setup(args)
                  inst.send before_method
                end
              end
            end

            private

            def controller_args(controller)
              args   = ActiveSupport::OrderedOptions.new
              params = controller.params
              if params[:id].present?
                record_var   = '@' + controller_resource_name.singularize
                args.scope   = controller.instance_variable_get(record_var)
              else
                record_var   = '@' + controller_resource_name
                args.scope   = controller.instance_variable_get(record_var)
              end
              args.params     = params
              args.controller = controller
              args.scope_name = record_var
              args
            end

            def set_options_before_action(options, default=false)
              method = options[:before_action]
              return if method == false
              method = '[action]' if method == true || (method.blank? && default.present?)
              return if method.blank?
              raise_error "before_action: #{method.inspect} must be a string or symbol."  unless valid_value?(method)
              options[:before_action] = method.to_s.gsub('[resource]', controller_resource_name)
            end

            def add_modules(options)
              totem_debug_message "adding filter modules:"  if debug?
              standardize_modules_from_options(options).each do |hash|
                add_filter_instance_methods(hash)
              end
            end

            def standardize_modules_from_options(options)
              array = Array.new
              array.push(options.except(:add))
              [options[:add]].flatten.compact.each do |add|
                array.push standardize_add_options(add)
              end
              array
            end

            def standardize_add_options(options)
              case
              when options.kind_of?(Hash)
                options
              when options.kind_of?(String) || options.kind_of?(Symbol)
                {name: options, module_name: options}
              else
                raise_error ":add options not a hash, string or symbol [#{options.inspect}]."
              end
            end

            def add_filter_instance_methods(options)
              name = get_options_name(options)
              mod  = get_options_module(options)
              return if mod.blank?
              inst = get_totem_filter_instance(mod)
              raise_error "Name #{name.inspect} module instance is blank." if inst.blank?
              set_options_before_action(options)
              filter_methods[name] = {
                instance:      inst,
                before_action: options[:before_action],
              }
              print_debug_add(name, mod, options)  if debug?
            end

            def get_options_module(options)
              mod   = options[:module]
              mname = options[:module_name]
              case 
              when mod == false
                return nil
              when mod.blank? && mname.blank? && !options[:is_controller]
                mod = get_controller_namespace_module(options[:name])
              when mod.blank? && mname.blank?
                mod = controller_module_name
              when mod.present? && mname.blank?
                raise_error "module: #{mod.inspect} must be a string or symbol."  unless valid_value?(mod)
                mod = mod.to_s
              when mod.blank? && mname.present?
                raise_error "module_name: #{mname.inspect} must be a string or symbol."  unless valid_value?(mname)
                mod = get_controller_namespace_module(mname)
              else
                raise_error "Cannot use both 'module: #{mod.inspect}' and 'module_name: #{mname.inspect}' in same add definition."
              end
              raise_error "Module is blank for name #{name.inspect}." if mod.blank?
              f_mod = mod.safe_constantize
              raise_error "Module #{mod.inspect} cannot be constantized."  if f_mod.blank?
              f_mod
            end

            def get_options_name(options)
              name = options[:name]
              raise_error "Name is blank in #{options.inspect}."  if name.blank?
              raise_error "name: #{name.inspect} must be a string or symbol."  unless valid_value?(name)
              raise_error "Name #{name.inspect} already exists."  if filter_methods.keys.include?(name)
              name.to_sym
            end

            def get_totem_filter_instance(mod)
              TotemFilter.new(mod)
            end

            def get_controller_namespace_module(name)
              controller_module_name.deconstantize + '::' + name.to_s.camelize  # replace controller's name with module name (in same namespace)
            end


            # ### Helpers
            def debug?; debug; end
            def valid_value?(value); value.kind_of?(String) || value.kind_of?(Symbol); end
            def has_filters?(args); args.params.has_key?(:filter); end
            def totem_debug_message(message); debug_message "totem_filter: #{message}"; end
            def debug_message(message); puts "[debug] #{message}"; end
            def raise_error(message); raise OptionsError, message; end

            # ### Errors
            class OptionsError < StandardError; end

            # ### TotemFilter
            # Encapsulate a filer module in a class.
            # Provides method name isolation if multiple filter modules are included in a controller (via add:).
            class TotemFilter
              attr_reader :params
              attr_reader :controller
              attr_reader :scope_name
              attr_reader :params_filters
              attr_reader :original_scope

              attr_accessor :results
              attr_accessor :scope
              attr_accessor :current_results

              def initialize(mod)
                raise TotemFilterOptionsError, "Module #{mod.inspect} is not a module."  unless mod.kind_of?(Module)
                extend mod
              end

              def setup(args)
                @params         = args.params
                @params_filters = JSON.parse(params[:filter])
                @controller     = args.controller
                @original_scope = args.scope
                @scope_name     = args.scope_name
                @scope          = original_scope # Used to modify the original scope.
                @results        = []
              end

              def set_scope(value)
                controller.instance_variable_set scope_name, value
              end


              def process_params_filters
                params_filters.each { |f| process_or_filters(f) }
                generate_scope
              end

              def process_or_filters(filters)
                @current_results = {}
                filters.each { |filter| process_filter(filter) }
                @results << current_results if current_results.present?
              end

              def process_filter(filter)
                method = filter['method']
                values = filter['values']
                self.send method, values if self.respond_to?(method) and method.include?('scope_by') # Ensure it is valid and includes `scope_by` for safety.
              end

              def add_result(key, values)
                values = Array.wrap(values)
                @current_results[key] ||= []
                @current_results[key] << values
                @current_results[key].flatten!.uniq!
              end

              def generate_scope
                @results.each do |result|
                  result.each do |column, value|
                    query         = {}
                    query[column] = value
                    @scope        = scope.where(query)
                  end
                end
                set_scope(@scope)
              end

            end
          end
        end
      end
    end
  end
end
