module Totem
  module Core
    module Config
      class Newrelic

        DEFAULT_OPTIONS = {
          NEW_RELIC_DEVELOPER_MODE: 'true',
          NEW_RELIC_MONITOR_MODE:   'false',
          NEW_RELIC_LOG_LEVEL:      'info',
          NEW_RELIC_APP_NAME:       'dev_app',
          NEW_RELIC_CAPTURE_PARAMS: 'true',
        }

        def self.process(config, options={})
          add_newrelic(options) if newrelic?
        end

        private

        def self.add_newrelic(options)
          hash = options.reverse_merge(DEFAULT_OPTIONS)
          Env.set_variables(hash)
          begin
            require 'newrelic_rpm'
          rescue LoadError
          else
            NewRelic::Agent.manual_start
          end
        end

        def self.newrelic?; ::Rails.env.development?; end

      end
    end
  end
end
