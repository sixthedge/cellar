== totem:db:reset
  rake totem:db:reset[folder-name] CONFIG=config1,config2...

    folder-name: [folder|none]
                 defaults to 'default' unless is string 'none'
                 folder-name must be a sub-folder under test_data

    CONFIG:      comma separated list of config file names
                 defaults to 'default'
                 config file names must be '_config_name.yml' e.g. _config_labs.yml
                 NOTE: config files are only run if the folder '_seed.rb' calls 'casespace_seed_configs_process'

    AUTO_INPUT|AI: [true|false]
                   defaults to 'false'
                   process the config 'auto_input' sections
                   NOTE: if the CONFIG name 'auto_input' is included, assues true
                   each config can have an auto_input section that will be run based on the value of AUTO_INPUT.

== Common casespace seed commands (e.g. copy/paste):

rake totem:db:reset                             #=> db/test_data/default/_config_default.yml
rake totem:db:reset CONFIG=default,auto_input   #=> db/test_data/default/_config_default.yml then db/test_data/default/_config_auto_input.yml

rake totem:db:reset[myconfigs] CONFIG=myconfig  #=> db/test_data/myconfigs/_myconfig.yml

rake db:drop; rake db:create; rake totem:db:reset CONFIG=default,labs,tags,teams,auto_input

== Test Seed Data

  * The seeds can be set by specifing the 'test_data_seed_name' in the rake command
    to require the "db/test data/#{test_data_seed_name}/_seed.rb" file.  This '_seed.rb' file can:

    * Require other dependent files (backward compatibility).
    * Use the '_config...yml' files by calling 'casespace_seed_configs_process' in the '_seed.rb'
    * Use a combination of requiring files and config files.
    * Use 'none' in the rake command as the 'test_data_seed_name' to skip loading any test data (e.g. only the production data).
      * rake totem:db:reset[none]

=== Examples

  * rake totem:db:reset[my_data]
    * require 'db/test_data/my_data/_seed.rb' (no config files used)

  * rake totem:db:reset[my_data] CONFIG=teams,lots_of_users
    * require 'db/test_data/my_data/_seed.rb'
    * process config files:
      * 'db/test_data/my_data/_config_teams.yml'
      * 'db/test_data/my_data/_config_lots_of_users.yml'

=== YAML Config files

  Config files formats must be supported by the 'db/helpers/casespace_seed_config_helper.rb'.

  Some supported implementations:
    * Create users, spaces, space users, assignments, phases
      * Repeat assignments and phases a specified number of times
      * Add a specified number of users
      * Share observation lists on specified phases
      * Space users can be add with a role (default is read)
    * Create teams and assign users/teams to peer review, collaboration and team-viewers
    * Create default input values for responses, observations, observation notes, and diagnostic paths (auto_input)

==== directives

prereq_configs:     [string|array] pre-requisite config for this config (do not include '_config' or '.yml'  e.g. default)
require_data_files: [folder-name]  require all 'test_data/folder-name/*.rb' files

==== prereq_configs

  NOTE:
    The '_config_default.yml' is processed if the rake command does not include CONFIG
    and config files are used.
    If CONFIG is included, only the configs listed are processed, therefore to inculde the
    '_config_default.yml' file, it needs to be a prereq config.

  Prereq configs can be specified in multiple config files.  The config files are
  processed in order with duplicates removed.  They can be nested up to 5 levels deep.

    prereq_configs:    #=> array of config hashes
      - config:        config-name
        namespace:     namespace-key (default :casespace)
        test_data_dir: test-data-dir-name (default rake command 'test_data_seed_name')
      - config:        another-config-name  (uses defaults)

    prereq_configs: config-name #=> one config short version (accepting defaults)

  Example:

    prereq_configs: default  #=> process the 'thinkspace-casespace/db/test_data/#{test_data_seed_name}/_config_default.yml'

==== require_data_files

  Requires all the test data files in the directory specified before processing the config file.
  Test data files are '.rb' files that do not start with '_'.
  Runs: @seed.require_data_files(namespace, test_data_dir)

  require_data_files: #=> array of config hashes
    - namespace:     namespace-key (default :casespace)
      test_data_dir: test-data-dir-name (directory within 'namespace/db/test_data/')

  Example:

    require_data_files: auto_input  #=> require data files in 'thinkspace-casespace/db/test_data/auto_input'


== MiniTest

  The seed helpers can be included in minitests (so do not need to duplicate the logic) by using
  the 'include_seed_helpers' method in casespace 'test_helper.rb'.

  include_seed_helpers(options)

    Options format: {namespace_key: [helper-filenames]}
    Filenames do not require '_helper.rb'
    e.g. {team: :team}, {casespace: [:assignment, :phase]}

  The helpers are encapsulated in the seed loader class to prevent method name collisions with the test methods.
  To reference: @seed.helpers.method-name