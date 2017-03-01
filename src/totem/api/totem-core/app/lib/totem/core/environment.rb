module Totem
  module Core
    class Environment

      attr_reader :configuration_support
      attr_reader :defaults_support
      attr_reader :registration_support
      attr_reader :engines_support
      attr_reader :authentication_support
      attr_reader :oauth_support
      attr_reader :authorization_support

      attr_reader :associations
      attr_reader :seeds_support

      attr_reader :option_ordered_options
      attr_reader :class_ordered_options
      attr_reader :module_ordered_options
      attr_reader :test_ordered_options

      def initialize
        @configuration_support  = Totem::Core::Support::Configuration.new(self)
        @defaults_support       = Totem::Core::Settings::Default.new(self)
        @registration_support   = Totem::Core::Support::Registration.new(self)
        @engines_support        = Totem::Core::Support::Engines.new(self)
        @authentication_support = Totem::Core::Support::Authentication.new(self)
        @oauth_support          = Totem::Core::Support::Oauth.new(self)
        @authorization_support  = Totem::Core::Support::Authorization.new(self)
        @seeds_support          = Totem::Core::Support::Seeds.new(self)
        @associations           = Totem::Core::Models::Associations.new(self)  # Totem::Settings.associations

        @option_ordered_options = ActiveSupport::OrderedOptions.new
        @class_ordered_options  = ActiveSupport::OrderedOptions.new
        @module_ordered_options = ActiveSupport::OrderedOptions.new
        @test_ordered_options   = ActiveSupport::OrderedOptions.new
      end

      # Support classes
      delegate :config,         to: :configuration_support  # Totem::Settings.config

      delegate :defaults,       to: :defaults_support       # Totem::Settings.defaults

      delegate :register,       to: :registration_support   # Totem::Settings.register
      delegate :registered,     to: :registration_support   # Totem::Settings.registered #=> alias for 'register'

      delegate :authentication, to: :authentication_support # Totem::Settings.authentication
      delegate :oauth,          to: :oauth_support          # Totem::Settings.oauth
      delegate :authorization,  to: :authorization_support  # Totem::Settings.authorization

      delegate :engine,         to: :engines_support        # Totem::Settings.engine
      delegate :engines,        to: :engines_support        # Totem::Settings.engines

      delegate :seed,           to: :seeds_support          # Totem::Settings.seed

      # Ordered Options
      alias_attribute :option, :option_ordered_options     # Totem::Settings.option

      alias_attribute :class,  :class_ordered_options      # Totem::Settings.class
      alias_attribute :classes,:class_ordered_options      # Totem::Settings.classes  #=> alias for 'class'

      alias_attribute :module, :module_ordered_options     # Totem::Settings.module

      alias_attribute :test, :test_ordered_options         # Totem::Settings.test (only used by Totem::Test engine)

    end
  end
end
