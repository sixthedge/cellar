class Travis
  class Opentbl
    class Staging
      class Api

        def self.before_install
          puts "Opentbl::Staging::Api before_install..."
        end

        def self.install
          commands = [
            'echo Installing API to $APP_INSTALL_API_DIR',
            'cd $APP_LOCAL_DIR',
            '$APP_LOCAL_DIR/install.sh --package opentbl/api --install $APP_INSTALL_API_DIR --platform thinkspace',
            'mkdir -p $APP_INSTALL_API_DIR/vendor/src/thinkspace/api',
            'mkdir -p $APP_INSTALL_API_DIR/vendor/src/totem/api',
            'mkdir -p $APP_INSTALL_API_DIR/.git',
            'cp -a $APP_SRC_DIR/thinkspace/api/. $APP_INSTALL_API_DIR/vendor/src/thinkspace/api/',
            'cp -a $APP_SRC_DIR/totem/api/. $APP_INSTALL_API_DIR/vendor/src/totem/api/',
            'cd $APP_INSTALL_API_DIR',
            'echo Bundling with $APP_BUNDLE_SRC',
            'bundle install'
          ]
          commands.each { |c| puts "Running: [#{c}]"; `#{c}` }
        end

      end
    end
  end
end