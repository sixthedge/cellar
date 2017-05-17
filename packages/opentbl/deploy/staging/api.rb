class Travis
  class Opentbl
    class Staging
      class Api

        def self.before_install
          puts "Opentbl::Staging::Api before_install..."
        end

        def self.install
          puts `echo Installing API to $APP_INSTALL_API_DIR`
          Dir.chdir(ENV['APP_LOCAL_DIR'])
          puts `./install.sh --package opentbl/api --install $APP_INSTALL_API_DIR --platform thinkspace`
          puts `mkdir -p $APP_INSTALL_API_DIR/vendor/src/thinkspace/api`
          puts `mkdir -p $APP_INSTALL_API_DIR/vendor/src/totem/api`
          puts `mkdir -p $APP_INSTALL_API_DIR/.git`
          puts `cp -a $APP_SRC_DIR/thinkspace/api/. $APP_INSTALL_API_DIR/vendor/src/thinkspace/api/`
          puts `cp -a $APP_SRC_DIR/totem/api/. $APP_INSTALL_API_DIR/vendor/src/totem/api/`
          Dir.chdir(ENV['APP_INSTALL_API_DIR'])
          puts `echo Bundling with $APP_BUNDLE_SRC`
          puts `bundle install`
        end

      end
    end
  end
end