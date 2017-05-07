module Totem
  module Core
    module Settings
      class ConfigClass

        attr_reader :class_map
        attr_reader :classes

        def initialize
          @class_map = ActiveSupport::OrderedHash.new
          @classes   = HashWithIndifferentAccess.new
        end

        def set_class(key, name)
          class_map[key.to_sym] = name
          check_class_exists(name)
        end

        def has_class?(key)
          class_map[key]
        end

        def get_class(method)
          name = class_map[method]
          error "Cannot find class associated with name [#{method.inspect}].  Is it defined?"   if name.blank?
          klass = name.safe_constantize
          error "Cannot contantize class name [#{name.inspect}]"  if klass.blank?
          klass
        end

        def get_class_name(key); class_map[key.to_sym]; end

        private

        def method_missing(method, *args)
          get_class(method)
        end

        def check_class_exists(name)
          return unless name.match(/Controller$/)  # if check models will cause problems with totem_associations
          klass = name.safe_constantize
          warning "Class [#{name.inspect}] does not currently exist"  unless klass.present?
        end

        include ::Totem::Core::Support::Shared

      end
    end
  end
end
