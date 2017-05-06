module Totem
  module Core
    module Config
      class Env

        def self.process(config, options={})
          config.before_configuration do
            load_and_set_variables
          end
        end

        def self.set_variables(hash={})
          hash.each do |key, value|
            skey = key.to_s
            next unless ENV[skey].nil? # existing ENV value has priority
            ENV[skey] = value
          end
          # print_environment_variables
        end

        private

        def self.load_and_set_variables
          env_file = Rails.root.join('config', 'totem', 'environment.yml')
          return unless File.file?(env_file)
          hash     = YAML.load(File.read(env_file))
          env      = ::Rails.env.dup
          env_hash = hash[env] || Hash.new
          set_variables(env_hash)
        end

        def self.print_environment_variables
          if ::Rails.env.development?
            from_msg = "[info] From (totem-core/lib/totem/core/config/env.rb)"
            env_msg  = "[info] Rails environment (#{Rails.env})"
            puts ''
            puts from_msg
            puts env_msg
            keys = ENV.keys.select {|k| k.start_with?('APP') || k.start_with?('RAILS')}.sort
            max  = keys.map {|k| k.to_s.length}.max + 2
            vmax = 120
            keys.each do |key|
              val = ENV[key] || ''
              if val.length > vmax
                val = val[0..vmax] + ' more...'
              end
              line = key.to_s.ljust(max, '.') + val.to_s
              puts '       ' + line
            end
            puts ''
          end
        end


      end
    end
  end
end
