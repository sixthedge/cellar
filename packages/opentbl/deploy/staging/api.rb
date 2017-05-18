class Travis
  class Opentbl
    class Staging
      class Api

        def self.local_dir; ENV['APP_LOCAL_DIR'];     end
        def self.api_dir; ENV['APP_INSTALL_API_DIR']; end

        def self.before_install
          puts "Opentbl::Staging::Api before_install..."
        end

        def self.install
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
          #puts `bundle install`
        end

        def self.deploy
          puts `echo Deploying OpenTBL::Staging...`
          Dir.chdir(api_dir)
          puts `openssl aes-256-cbc -K $encrypted_c1bb17deeea4_key -iv $encrypted_c1bb17deeea4_iv -in $TRAVIS_BUILD_DIR/test.sh.enc -out test.sh -d`
          puts `chmod ugo+x test.sh`
          puts `ls -l`
          puts `. ./test.sh && echo $TEST_VAR zz`
          puts `echo $TEST_VAR --`
          #puts `dpl --provider=heroku --api-key=$HEROKU_API_KEY --app=opentbl-staging --skip_cleanup=true`
        end

      end
    end
  end
end