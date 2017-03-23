  # Rack CORS configuration
  config.middleware.insert_before 0, 'Rack::Cors' do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :put, :delete, :post, :options, :patch]
    end
  end

  # Paperclip Storage
  config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: {
     bucket:            Rails.application.secrets.aws.dig('s3', 'paperclip', 'bucket_name'),
     access_key_id:     Rails.application.secrets.aws.dig('s3', 'paperclip', 'access_key'),
     secret_access_key: Rails.application.secrets.aws.dig('s3', 'paperclip', 'secret_access_key')
    },
    s3_protocol: :https,
    s3_region:   Rails.application.secrets.aws.dig('s3', 'paperclip', 'region'),
    path:        ':paperclip_path'
  }

  paperclip_access_key = Rails.application.secrets.aws.dig('s3', 'paperclip', 'access_key')
  if paperclip_access_key.blank?
    config.paperclip_defaults.merge!(storage: :filesystem, path: ':dev_paperclip_path', url: ':dev_url_path', use_timestamp: false)
  end

  # Mailcatcher SMTP
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings   = { address: 'localhost', port: 1025 }

  Slim::Engine.options[:pretty] = true

  # Controller caching
  config.action_controller.perform_caching = true
  config.action_controller.cache_store     = :memory_store

  # NewRelic RPM
  ENV['NEW_RELIC_DEVELOPER_MODE'] = 'true'
  ENV['NEW_RELIC_MONITOR_MODE']   = 'false'
  ENV['NEW_RELIC_LOG_LEVEL']      = 'info'
  ENV['NEW_RELIC_APP_NAME']       = 'dev_app'
  ENV['NEW_RELIC_CAPTURE_PARAMS'] = 'true'
  begin
    require 'newrelic_rpm'
  rescue LoadError
  else
    NewRelic::Agent.manual_start
  end

  config.after_initialize do
    # ### Trigger the totem associations to create the model associations and serializers
    # ### to speed up the initial login (do not do when running rails c or a rake task).
    unless (defined?(::Rails::Console) || File.split($0).last == 'rake')
       # Thinkspace::Common::User.first
    end

    # ### If using the Rails console, do not define serializers
    if defined?(::Rails::Console)
      ENV['TOTEM_STARTUP_NO_SERIALIZERS'] = 'true'
    end
  end
