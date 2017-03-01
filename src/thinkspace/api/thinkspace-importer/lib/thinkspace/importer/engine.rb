module Thinkspace
  module Importer
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Importer
      engine_name 'thinkspace_importer'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_importer',
          platform_type:  'thinkspace',
          platform_name:  'thinkspace',
          platform_path:  'thinkspace',
          platform_scope: 'thinkspace',
          platform_sub_type: 'importer'
        )
      end

    end
  end
end