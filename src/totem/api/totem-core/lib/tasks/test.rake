require File.expand_path('../test_totem_helper', __FILE__) 

namespace :totem do

  test_namespace = namespace :test do

    # Usage (ENV variables):
    #  verbose  : TESTOPTS='--verbose' e.g. rake TESTOPTS='--verbose' totem:test:all
    #  coverage : COVERAGE=true        e.g. rake COVERAGE=true totem:test:unit:all
    #  warning  : WARNING=true         e.g. rake WARNING=true totem:test:unit:all
    #             #=> sets warning=true in Rake::TestTask which uses 'ruby -w'
    #             #=> caution: may create a number of test-unrelated warnings
    #  
    #  Multipe ENV variables can be supplied: e.g. rake TESTOPTS='--verbose' COVERAGE=true totem:test:all
    #  The short version can be used in TESTOPTS if perfered e.g. verbose: rake TESTOPTS='-v' totem:test:all
    #  Other valid test options can be added in the TESTOPTS.
    #  Rake options can be used e.g. rake --trace rake:test:unit:all
    #

    # rake totem:test:all
    desc "Run all tests with db:prepare"
    task :all, [:engine_name] do |t, args|
      include TestTotemHelper
      totem_all_test_task totem_get_options(args, all: true)
    end

    # rake totem:test:engine[engine_name,path,path,...]
    desc "Run engine tests with db:prepare"
    task :engine, [:engine_name] do |t, args|
      include TestTotemHelper
      totem_engine_test_task totem_get_options(args)
    end

    # ### UNIT TESTS ### #
    unit_namespace = namespace :unit do

      # rake totem:test:unit:all
      desc "Run all tests as unit tests (e.g. no db:prepare)"
      task :all, [:engine_name] do |t, args|
        include TestTotemHelper
        totem_all_test_task totem_get_options(args, unit: true, all: true)
      end

      # rake totem:test:unit:engine[engine_name,path,path,...]
      desc "Run engine tests as unit tests (e.g. no db:prepare)"
      task :engine, [:engine_name] do |t, args|
        include TestTotemHelper
        totem_engine_test_task totem_get_options(args, unit: true)
      end

    end

  end

end
