module Totem
  module Core
    module Config
      class Smtp

        def self.process(config=nil, options={})
          smtp(config, options)
          slim(options)
        end

        private

        def self.smtp(config, options)
          case
          when ::Rails.env.development?  then development(config, options)
          else                                production(config, options)
          end
        end

        def self.development(config, options)
          port    = options[:smtp_port]    || 1025
          address = options[:smtp_address] || 'localhost'
          config.action_mailer.delivery_method = :smtp
          config.action_mailer.smtp_settings   = {
            address: address,
            port: port,
          }
        end

        def self.production(config, options)
          port    = options[:smtp_port]    || 587
          address = options[:smtp_address] || 'smtp.postmarkapp.com'
          config.action_mailer.smtp_settings = {
            address:              address,
            port:                 port,
            enable_starttls_auto: true,
            user_name:            Rails.application.secrets.smtp['postmark']['username'],
            password:             Rails.application.secrets.smtp['postmark']['password'],
            domain:               Rails.application.secrets.smtp['postmark']['domain'],
            authentication:       :cram_md5
          }
        end

        def self.slim(options)
          Slim::Engine.options[:pretty] = true
        end

      end
    end
  end
end
