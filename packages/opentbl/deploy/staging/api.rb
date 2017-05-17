class Travis
  class Opentbl
    class Staging
      class Api

        def self.before_install
          puts "Opentbl::Staging::Api before_install..."
        end

        def self.install
          local_dir = ENV['APP_LOCAL_DIR']
          api_dir   = ENV['APP_INSTALL_API_DIR']
          puts `echo Installing API to $APP_INSTALL_API_DIR`
          Dir.chdir(local_dir)
          puts `./install.sh --package opentbl/api --install $APP_INSTALL_API_DIR --platform thinkspace`
          puts `mkdir -p $APP_INSTALL_API_DIR/vendor/src/thinkspace/api`
          puts `mkdir -p $APP_INSTALL_API_DIR/vendor/src/totem/api`
          puts `mkdir -p $APP_INSTALL_API_DIR/.git`
          puts `cp -a $APP_SRC_DIR/thinkspace/api/. $APP_INSTALL_API_DIR/vendor/src/thinkspace/api/`
          puts `cp -a $APP_SRC_DIR/totem/api/. $APP_INSTALL_API_DIR/vendor/src/totem/api/`
          Dir.chdir(api_dir)
          puts `echo Bundling with $APP_BUNDLE_SRC`
          puts `bundle install`
        end

        def self.deploy
          puts `echo Deploying OpenTBL::Staging...`
          Dir.chdir(api_dir)
          puts `dpl --provider=heroku --api-key=$TEST`
        end

      end
    end
  end
end