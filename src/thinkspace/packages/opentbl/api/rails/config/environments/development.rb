Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # ###################################################
  # ### Development Platform Specific Configuration ###
  # ###################################################

  # ### thinkspace ### #

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
         bucket:            Rails.application.secrets.aws['s3']['paperclip']['bucket_name'],
         access_key_id:     Rails.application.secrets.aws['s3']['paperclip']['access_key'],
         secret_access_key: Rails.application.secrets.aws['s3']['paperclip']['secret_access_key']
       },
   s3_protocol: :https
  }

  # Postmark SMTP
  config.action_mailer.smtp_settings = {
    address:              'smtp.postmarkapp.com',
    port:                 587,
    enable_starttls_auto: true,
    user_name:            Rails.application.secrets.smtp['postmark']['username'],
    password:             Rails.application.secrets.smtp['postmark']['password'],
    domain:               Rails.application.secrets.smtp['postmark']['domain'],
    authentication:       :cram_md5
  }

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

    # ### Set Paperclip to use local file storage if S3 secrets not set.
    paperclip_access_key = Rails.application.secrets.dig('s3', 'paperclip', 'access_key')
    if paperclip_access_key.blank? || paperclip_access_key.match('-HERE')

      Paperclip::Attachment.default_options.merge!(storage: :filesystem, path: ':dev_override_path/:filename', url: ':url_path/:filename', use_timestamp: false)
      Paperclip::Interpolations.send :alias_method, :original_artifact_path, :artifact_path

      Paperclip.interpolates :artifact_path do |attachment, style|
        result = original_artifact_path(attachment, style)
        'public/paperclip/' + result
      end

      Paperclip.interpolates :dev_override_path do |attachment, style|
        result = "#{attachment.instance.class.name.underscore}/#{attachment.instance.id}"
        'public/paperclip/' + result
      end

      Paperclip.interpolates :url_path do |attachment, style|
        result = attachment.instance.is_a?(Thinkspace::Artifact::File) ? artifact_path(attachment, style) : dev_override_path(attachment, style)
        'http://localhost:3000/' + result.sub(/^public\//,'')
      end
    end

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


end
