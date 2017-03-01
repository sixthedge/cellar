require 'smarter_csv'

module Thinkspace
  module Common
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Common
      engine_name 'thinkspace_common'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_common',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'common',
        )
      end

      initializer 'platform.registration', after: 'framework.platform.registration' do |app|
        ::Totem::Settings::register.platform('thinkspace', 'thinkspace/common')
      end

    end
  end
end
