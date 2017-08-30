module Thinkspace
  module Stripe
    class Engine < ::Rails::Engine

      isolate_namespace Thinkspace::Stripe     
      engine_name 'thinkspace_stripe'

      initializer 'engine.registration', after: 'framework.registration' do |app|
        ::Totem::Settings.register.engine('thinkspace_stripe',
          platform_name:     'thinkspace',
          platform_path:     'thinkspace',
          platform_scope:    'thinkspace',
          platform_sub_type: 'wips',
        )
      end

    end
  end
end
