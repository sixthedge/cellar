module Totem
  module Core
    module Controllers
      module TotemActionSerializerOptions

        extend ::ActiveSupport::Concern

        module ClassMethods
          # Adds a class method to a controller class, adds a before filter to call the controller's serializer
          # options module plus any additional modules defined.
          # Adds a class attribute with Rails 'cattr_reader' that is accessible from the controller class or any
          # instances of the controller class.
          # Options:
          #   * Rails standard before_action options 'only', 'except', 'if', 'unless'
          #   * name:          [string|symbol] name of the serializer module
          #:                   * controller default is 'controller_class.name.demodulized.sub(/Controller$/, '').underscore'
          #:                   * name is required (other than the controller which uses the default name if not provided)
          #:                   * If not used in controller code e.g. totem_serializer_options.name(parameters...), the name
          #:                   is only used internally to reference the module.
          #   * module:        [string|symbol|false]
          #:                   * string|symbol = use this fully-qualified module name
          #:                   * false         = do not add a serializer options module to be called
          #:                   * not provided  =
          #:                   - if :module_name present, use the :module_name
          #:                   - elsif controller, use controller.class.name.sub('::Api', '::Concerns::SerializerOptions').sub(/Controller$/, '')
          #:                   - elsif :module_name blank, use :name as the :module_name
          #:                   - else error
          #   * module_name:   [string|symbol] appended to the controller's deconstantized-module-name
          #:                   * Useful to reference another module in the controller's namespace but with a different module name
          #   * before_action: [string|symbol|true|false] default true for controller; false for options' add: hashes
          #:                   * if true, call serializer options module's 'action' method in before_action e.g. index, show, ...
          #:                   * if false, must manually call in controller code
          #:                   * if string|symbol (same as true), call the string|symbol method instead of the 'action' method in the before_action
          #:                   - when a string, can add to replacement variables
          #:                   -- [action]   = replace with current controller action
          #:                   -- [resource] = replace with controller resource (e.g. the controller's demodulized name)
          #:                   -- Example for a UsersController index request:
          #:                   ---before_action: '[resource]_[action]_special_options' -> 'users_index_special_options'
          #   * add:           [hash|array|string|symbol]
          #:                   * hash of :name, :module, :module_name and :before_action
          #:                   * a string or symbol value converted to hash {name: value, module_name: value}
          #:                   * an array's elements are converted per above
          #   * debug          [true|false] print debug messages on console
          #
          # When manually calling the serailizer options modules, parameters passed must match the method's expected parameters.
          # 
          # Typical use:
          #   class UsersController
          #     totem_action_serailizer_options
          #
          #   1. Add the controller's serializer options module with name 'users'.
          #   2. On each request (in before filter), call the 'users' module action method passing the 'serializer_options'  e.g. index, show, etc.
          #   3. If needed, in the controller code: totem_serializer_options.method-name(serializer_options, param1, param2, ...); assumes 
          #      users module has a 'method-name' method defined.
          #
          def totem_action_serializer_options(*args)
            cattr_reader :totem_serializer_options  # controller class variable referencing the 'instance' of TotemControllerSerializerOptions
            options       = args.extract_options!
            self.class_variable_set '@@totem_serializer_options', TotemControllerSerailizerOptions.new(self, options)
            before_method = options[:prepend] ? :prepend_before_action : :before_action
            self.send(before_method, options.slice(:only, :except, :if, :unless)) do |controller|
              totem_serializer_options.before_action_process(controller)
            end
          end

          # Class that encapsulate the class method 'totem_action_serializer_options' values so the controller's class
          # only has one class method.
          # Loads and encapsulates all serializer options modules into an instance of class TotemSerializerOptions
          # and adds to a hash with hash[:name] with the instance.
          class TotemControllerSerailizerOptions

            def initialize(controller_class, options={})
              @serializer_options_methods = Hash.new
              @controller_module_name     = controller_class.name.sub('::Api', '::Concerns::SerializerOptions').sub(/Controller$/, '')
              @controller_resource_name   = controller_class.name.demodulize.sub(/Controller$/, '').underscore
              @debug                      = options[:debug] == true
              options[:name]              = options[:name] || controller_resource_name
              options[:is_controller]     = true  # allow non-controller modules to default to :name if :module_name is blank
              set_options_before_action(options, true)
              add_modules(options)
            end

            # Public method called by the before_action to call the module methods.
            def before_action_process(controller)
              serializer_options_methods.each do |method_name, hash|
                before_method = hash[:before_action]
                next if before_method.blank?
                action        = controller.action_name
                before_method = before_method.to_s.gsub('[action]', action)
                inst          = hash[:instance]
                raise_error "Module #{method_name.inspect} instance is blank." if inst.blank?
                raise_error "Module #{method_name.inspect} does not respond to #{before_method.inspect}." unless inst.respond_to?(before_method)
                totem_debug_message "before filter calling '#{method_name}##{before_method}'"  if debug?
                case inst.method(before_method).arity
                when 0
                  method_args = []
                when 1
                  method_args = [serializer_options(controller)]
                when 2, -1, -2
                  method_args = [serializer_options(controller), controller_args(controller)]
                else
                  raise_error "Module #{method_name.inspect}##{before_method.inspect} requires more than 2 arguments (only 0, 1 or 2 permitted)"
                end
                inst.send before_method, *method_args
              end
            end

            # Public helper to return the arguments when controller code directly calls a module method requiring args.
            # e.g. totem_serializer_options.mod-name.show serailizer_options, totem_serializer_options.controller_args(self)
            # Note: this is only required if the module method is also a controller action method (e.g. may be called
            # in the before filter), otherwise the module method arguments can be anything needed.
            def controller_args(controller)
              args   = ActiveSupport::OrderedOptions.new
              params = controller.params
              if params[:id].present?
                record_var   = '@' + controller_resource_name.singularize
                args.record  = controller.instance_variable_get(record_var)
                args.records = nil
              else
                record_var   = '@' + controller_resource_name
                args.records = controller.instance_variable_get(record_var)
                args.record  = nil
              end
              args.params                   = params
              args.serializer_options       = serializer_options(controller)
              args.current_ability          = controller.send :current_ability
              args.current_user             = controller.send :current_user
              args.totem_serializer_options = controller.totem_serializer_options
              args.controller               = controller
              args
            end

            private

            # Helper to standardize getting the serializer options from the controller.
            def serializer_options(controller)
              controller.send :serializer_options
            end

            # Override method_missing to call a method on an instance variable (that references a serializer options module).
            # Allows 'totem_serializer_options' module methods to be called by controller code outside of before_action.
            def method_missing(method_name, *args, &block)
              if serializer_options_methods.keys.include?(method_name)
                totem_debug_message "returning instance for #{method_name}."  if debug?
                serializer_options_methods[method_name][:instance]
              else
                super
              end
            end

            # Methods that handle the 'totem_action_serializer_options' options.

            attr_reader :serializer_options_methods
            attr_reader :controller_module_name
            attr_reader :controller_resource_name
            attr_reader :debug

            def set_options_before_action(options, default=false)
              method = options[:before_action]
              return if method == false
              method = '[action]' if method == true || (method.blank? && default.present?)
              return if method.blank?
              raise_error "before_action: #{method.inspect} must be a string or symbol."  unless valid_value?(method)
              options[:before_action] = method.to_s.gsub('[resource]', controller_resource_name)
            end

            def add_modules(options)
              totem_debug_message "adding serializer modules:"  if debug?
              standardize_modules_from_options(options).each do |hash|
                add_serializer_options_instance_methods(hash)
              end
            end

            def add_serializer_options_instance_methods(options)
              name = get_options_name(options)
              mod  = get_options_module(options)
              return if mod.blank?
              inst = get_totem_serializer_options_instance(mod)
              raise_error "Name #{name.inspect} module instance is blank." if inst.blank?
              set_options_before_action(options)
              serializer_options_methods[name] = {
                instance:      inst,
                before_action: options[:before_action],
              }
              print_debug_add(name, mod, options)  if debug?
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
              so_mod = mod.safe_constantize
              raise_error "Module #{mod.inspect} cannot be constantized."  if so_mod.blank?
              so_mod
            end

            def get_options_name(options)
              name = options[:name]
              raise_error "Name is blank in #{options.inspect}."  if name.blank?
              raise_error "name: #{name.inspect} must be a string or symbol."  unless valid_value?(name)
              raise_error "Name #{name.inspect} already exists."  if serializer_options_methods.keys.include?(name)
              name.to_sym
            end

            def get_controller_namespace_module(name)
              controller_module_name.deconstantize + '::' + name.to_s.camelize  # replace controller's name with module name (in same namespace)
            end

            def valid_value?(value); value.kind_of?(String) || value.kind_of?(Symbol); end

            def debug?; debug; end

            def totem_debug_message(message); debug_message "totem_action_serializer_options: #{message}"; end

            def debug_message(message); puts "[debug] #{message}"; end

            def print_debug_add(name, mod, options)
              debug_message "  name: #{name.inspect}"
              debug_message "    module: #{mod.inspect}"
              debug_message "    before filter: #{options[:before_action].inspect}"
            end

            def raise_error(message)
              raise OptionsError, message
            end

            def get_totem_serializer_options_instance(mod)
              TotemSerializerOptions.new(mod)
            end

            # Encapsulate a serializer options module in a class.
            # Provides method name isolation if multiple serializer options modules are included in a controller (via add:).
            class TotemSerializerOptions
              def initialize(mod)
                raise TotemSerializerOptionsError, "Module #{mod.inspect} is not a module."  unless mod.kind_of?(Module)
                extend mod
              end
              private
            end

          end

          class OptionsError < StandardError; end

        end

      end
    end
  end
end
