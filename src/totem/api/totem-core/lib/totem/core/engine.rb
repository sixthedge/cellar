module Totem
  module Core
    class Engine < ::Rails::Engine

      isolate_namespace Totem::Core
      engine_name 'totem_core'

      initializer 'framework.environment', before: :load_config_initializers do |app|
        ::Totem::Settings = app.config.totem = Totem::Core::Environment.new
      end

      # Once core is initialized, other engines can register since they use
      # after: 'framework.registration'.
      initializer 'framework.registration', after: :load_config_initializers do |app|
        ::Totem::Settings.register.engine('totem_core')
      end

      # After the other engines have registered (triggered by framework.registration),
      # register the framework itself.
      # Need to wait to register the framework platform after other engines
      # have registered as registering the framework platform will read the
      # config.yml files which matches the paths to the engines.
      initializer 'framework.platform.registration', after: 'engine.registration' do |app|
        ::Totem::Settings.register.framework('totem', 'totem/core')
      end

    end
  end
end
