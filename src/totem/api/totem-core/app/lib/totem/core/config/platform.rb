module Totem
  module Core
    module Config
      class Platform

        def self.process(config, options={})
          env_variables(config, options) unless options[:env]        == false
          after_init(config, options)    unless options[:after_init] == false
          newrelic(config, options)      unless options[:newrelic]   == false
          paperclip(config, options)     unless options[:paperclip]  == false
          rack_cors(config, options)     unless options[:rack_cors]  == false
          smtp(config, options)          unless options[:smtp]       == false
        end

        def self.env_variables(config, options={}); ::Totem::Core::Config::Env.process(config, options); end
        def self.after_init(config, options={});    ::Totem::Core::Config::ModelSerializers.process(config, options); end
        def self.newrelic(config, options={});      ::Totem::Core::Config::Newrelic.process(config, options);  end
        def self.paperclip(config, options={});     ::Totem::Core::Config::Paperclip.process(config, options); end
        def self.rack_cors(config, options={});     ::Totem::Core::Config::RackCors.process(config, options);  end
        def self.smtp(config, options={});          ::Totem::Core::Config::Smtp.process(config, options);  end

      end
    end
  end
end
