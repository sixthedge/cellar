module Totem
  module Core
    module Config
      class Paperclip

        def self.process(config, options={})
          return unless paperclip?
          s3(config, options)
          local_filesystem(config, options) if local_filesystem?
        end

        private

        def self.s3(config, options={})
          config.paperclip_defaults = {
            storage: :s3,
            s3_credentials: {
              access_key_id:     get_access_key,
              bucket:            get_bucket,
              secret_access_key: get_secret_access_key,
             },
             s3_protocol: :https
          }
        end

        def self.local_filesystem(config, options={})
          config.paperclip_defaults = {
            storage:       :filesystem,
            path:          ':dev_paperclip_path',
            url:           ':dev_url_path',
            use_timestamp: false,
          }
        end

        def self.paperclip?; defined?(::Paperclip); end

        def self.local_filesystem?; ::Rails.env.development? && get_access_key.blank?; end

        def self.get_access_key;        ::Rails.application.secrets.dig('s3', 'paperclip', 'access_key'); end
        def self.get_bucket;            ::Rails.application.secrets.dig('s3', 'paperclip', 'bucket_name'); end
        def self.get_secret_access_key; ::Rails.application.secrets.dig('s3', 'paperclip', 'secret_access_key'); end

      end
    end
  end
end
