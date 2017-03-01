module Totem
  module Core
    module Settings
      class ConfigModule

        attr_reader :module_map
        attr_reader :modules
    
        def initialize
          @module_map = ActiveSupport::OrderedHash.new
          @modules    = HashWithIndifferentAccess.new
        end

        def set_module(key, name)
          module_map[key.to_sym] = name
          check_module_exists(name)
        end

        def get_all
          module_map.keys.collect { |method| get_module(method) }
        end

        def has_module?(key)
          module_map[key]
        end

        def get_module(method)
          name = module_map[method.to_sym]
          error "Cannot find module associated with name [#{method.inspect}].  Is it defined?"   if name.blank?
          mod = name.safe_constantize
          error "Cannot contantize module name [#{name.inspect}]"  if mod.blank?
          mod
        end

        private

        def method_missing(method, *args)
          get_module(method)
        end

        def check_module_exists(name)
          # return unless name.match(/Controller$/)  # if check models will cause problems with totem_associations
          mod = name.safe_constantize
          warning "Module [#{name.inspect}] does not currently exist"  unless mod.present?
        end

        include ::Totem::Core::Support::Shared

      end
    end
  end
end