module Totem
  module Core
    module Config
      class ModelSerializers

        def self.process(config, options={})
          config.after_initialize do
            init_models(options)             unless options[:init_models] == false
            console_serializers_off(options) unless options[:console_serializers_off] == false
          end
        end

        private

        # Trigger the totem associations to create the model associations and serializers
        # to speed up the initial login (do not do when running rails c or a rake task).
        def self.init_models(options)
          unless ( console? || rake_task? )
            name       = ::Totem::Settings.registered.platform_name
            user_class = ::Totem::Settings.authentication.platform(name).classes.get_class_name(:user_model)
            user_class.safe_constantize if user_class.present?
          end
        end

        # If using the Rails console, do not define serializers.
        # Serializers are generated via the first a console command referencing a model.
        def self.console_serializers_off(options)
          if console?
            ::Totem::Core::Config::Env.set_variables(TOTEM_STARTUP_NO_SERIALIZERS: 'true')
          end
        end

        def self.console?; defined?(::Rails::Console); end

        def self.rake_task?; File.split($0).last == 'rake'; end

      end
    end
  end
end
