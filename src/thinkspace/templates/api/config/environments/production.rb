  # Rack CORS configuration
  config.middleware.insert_before 0, 'Rack::Cors' do
    allow do
      origins '*'
      resource '*.woff', headers: :any, methods: :get
      resource '*.eot',  headers: :any, methods: :get
      resource '*.svg',  headers: :any, methods: :get
      resource '*.ttf',  headers: :any, methods: :get
    end
  end

  # Paperclip Storage
  config.paperclip_defaults = {
     storage: :s3,
       s3_credentials: {
         bucket: Rails.application.secrets.aws['s3']['paperclip']['bucket_name'],
         access_key_id: Rails.application.secrets.aws['s3']['paperclip']['access_key'],
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

  config.cache_store = :dalli_store,
  (ENV["MEMCACHIER_SERVERS"] || "").split(","),
    {:username => ENV["MEMCACHIER_USERNAME"],
    :password => ENV["MEMCACHIER_PASSWORD"],
    :failover => true,
    :socket_timeout => 1.5,
    :socket_failure_delay => 0.2
    }
