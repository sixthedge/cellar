require 'pp'
require 'active_support/inflector'

class Travis
  class Parser
    attr_accessor :deploys
    attr_reader :message

    def initialize
      @deploys = {}
      @message = Travis.commit_message
      process
    end

    def process
      process_deploys
    end

    def process_deploys
      matches = @message.scan(/\[deploy \w+\/\w+\/?\w+\]/)
      matches.each do |match|
        match.tr!('[]', '')
        split       = match.split(' ')
        parts       = split[1]
        split       = parts.split('/')
        package     = split[0]
        environment = split[1]
        server      = split[2] || nil
        set_deploy(package, environment, server)
      end
    end

    def set_deploy(package, environment, server)
      server = 'all' if server == nil
      @deploys[package] ||= {}
      @deploys[package][environment] ||= {}
      @deploys[package][environment]['servers'] ||= []
      @deploys[package][environment]['servers'].push(server)
    end

  end #/ Class Parser

  def self.before_install; process_hook('before_install'); end
  def self.install;        process_hook('install');        end
  def self.before_script;  process_hook('before_script');  end
  def self.script;         process_hook('script');         end
  def self.after_script;   process_hook('after_script');   end
  def self.before_deploy;  process_hook('before_deploy');  end
  def self.deploy;         process_hook('deploy');         end 
  def self.after_deploy;   process_hook('after_deploy');   end
  def self.dotenv;         get_dotenv;                     end

  # # Helpers
  # ## Hooks
  def self.process_hook(hook)
    deploys = Travis::Parser.new.deploys
    deploys.each do |package, environments|
      environments.each do |environment, options|
        servers = options['servers']
        if servers.include?('all')
          run_hook_all(hook, package, environment)
        else
          servers.each { |server| run_hook(hook, package, environment, server) }
        end
      end
    end
  end

  def self.run_hook_all(hook, package, environment)
    path  = get_path(package, environment)
    files = Dir["#{path}/*.rb"]
    files.each do |file|
      server = file.split('/').pop.gsub('.rb', '')
      run_hook(hook, package, environment, server)
    end
  end

  def self.run_hook(hook, package, environment, server)
    klass = get_class(package, environment, server)
    file  = get_file(package, environment, "#{server}.rb")
    if File.file?(file)
      puts "klass: [#{klass}] -- file: [#{file}]"
      if klass
        require(file)
        klass = klass.safe_constantize
        if klass && klass.respond_to?(hook)
          notify "Running [#{hook}] for [#{klass.name}]..."
          klass.send(hook)
        end
      end
    else
      warn "Could not find class: [#{klass}] with file: [#{file}], skipping..."
    end
  end

  # ## Getters
  def self.get_class(package, environment, server)
    "travis/#{package}/#{environment}/#{server}".classify
  end

  def self.get_path(package, environment)
    "#{cellar_root}/packages/#{package}/deploy/#{environment}"
  end

  def self.get_file(package, environment, file_name)
    get_path(package, environment) + "/#{file_name}"
  end

  def self.get_dotenv
    commands = []
    deploys  = Travis::Parser.new.deploys
    deploys.each do |package, environments|
      environments.each do |environment, options|
        encrypted = get_file(package, environment, '.env.enc')
        puts "ENCRYPTED IS: #{encrypted}"
        decrypted = ".env-#{environment}"
        decrypt   = "openssl aes-256-cbc -K $encrypted_c1bb17deeea4_key -iv $encrypted_c1bb17deeea4_iv -in #{encrypted} -out #{decrypted} -d"
        commands.push(decrypt)
        source    = ". #{decrypted}"
        commands.push(source)
      end
    end
    puts commands.join(' && ')
  end

  def self.commit_message; ENV['TRAVIS_COMMIT_MESSAGE'] || '[deploy opentbl/staging/api] [deploy opentbl/staging/client]'; end
  def self.cellar_root; ENV['TRAVIS_BUILD_DIR'] || '..'; end

  # ## Messaging
  def self.notify(message); puts("#{message}"); end
  def self.warn(message); puts("[WARN] #{message}"); end

end
