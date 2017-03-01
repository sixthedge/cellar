require 'paperclip'

module Thinkspace
  module Resource
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Resource
      engine_name 'thinkspace_resource'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_resource',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'dock'
        )
      end

    end
  end
end