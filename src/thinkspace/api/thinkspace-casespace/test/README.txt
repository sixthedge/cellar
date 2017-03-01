Test Rake task test selection:

  rake totem:test:unit:engine[engine_name,pattern]  #=> pattern is any Dir.glob pattern

  Individual test files must end in '_test.rb'

  Examples of patterns:
  
    engine name only:  [thinkspace_casespace]                  #=> all test files matching test/**/*_test.rb
    folders in order:  [thinkspace_casespace,ability]          #=> all tests in test/ability
    folders in order:  [thinkspace_casespace,ability,mytests]  #=> all tests in test/ability/mytests
    folders and tests: [thinkspace_casespace,ability,route*]   #=> all tests in test/ability matching route*_test.rb
  
    To include some tests (can only use on the last pattern arg):
      [thinkspace-casespace,ability:clone]   #=> all tests in test/ability and test/clone

  Files in the 'helpers' folder are excluded.

  Rake Examples:
    Populate test db with a seed:
      rake totem:db:reset RAILS_ENV='test' CONFIG=ability
      rake totem:db:reset[default] RAILS_ENV='test' CONFIG=all  #=> load all dev configs into test db

    Run tests:
      rake totem:test:unit:engine[thinkspace_casespace] BACKTRACE=1 SEED=true  #=> all thinkspace-casespace tests
      rake totem:test:unit:engine[thinkspace_casespace,ability,routes] BACKTRACE=1 SEED=true

    Note: When need a full backtrace on 'errors' (e.g. not failures) add BACKTRACE=1.

Structure:

  rails root
    |- test
       |- helpers
          |- main-helper-file.rb
          |- main-helper-folder
             |- main-helper-helper-files.rb (typically main helper specific modules)
       |- test-folder (contain the actual tests)
          |- some_test.rb

  The 'helpers' directory is added to the Rails load path by totem:test.
  All helpers are 'required' so the file name does not need to match the module path name (but is a good practice).

  The test-folders are organzational but can be helpful to identify helper module names.

  The main helpers should include at least:
    require 'casespace_helper'                             # required
    require_test_helper_files(main-helper-helpers-folder)  # only required if have additional helper modules

    Example of ability_helper.rb
      require 'casespace_helper'
      require_test_helper_files(:ability)

  Each test file related to this main helper must include the main helper.
    Example of an ability test file:
      require 'ability_helper'


  Helpers are broken into modules for a specific use.
  The 'helpers/casespace' modules are mostly generic and can be included in any test.
  The caspace_helper.rb requires all of the 'helpers/casespace' modules.
  To include all 'helpers/casespace' modules in a test, can use the convience module Casespace::All.

Seeds:

  IMPORTANT: If the db schema has changed, need to run:
    rake totem:db:reset[none] RAILS_ENV='test'

  A config file in the thinkspace-casespace/db/test_data/test folder can be loaded before the test by
  calling 'Test::Casespace::Seed.load(config: :config-name)' before the test class.
  A config file name will be loaded only once per rake task.
  Multiple config file names can loaded per rake task.

  The first config file loaded will truncate all of the tables before loading the database.
  Domain data is also after truncating the tables.

  Add SEED=true to the test rake task.

  IF SEED != true (e.g. SEED= not added or not set to true) then the seed configs are not processed (nor tables truncated).
  Useful when running/debugging tests multiple times.

  Examples:
    require 'ability_helper'
    Test::Casespace::Seed.load(config: :ability)  #=> add 'auto_input: true' for auto inputs
    module Test; module Ability; class Routes < ActionController::TestCase
    ...

    rake totem:test:unit:engine[thinkspace_casespace,ability] BACKTRACE=1 SEED=true

    Note: BACKTRACE=1 will add additional trace information on 'errors'.

Routes:

  Most of the current tests are 'route' based, meaning they are based on each engine's
  'config/routes' to identify the per route controller class, action, verb and type (e.g. member or collection).

  Tests are run in loop for each route with up to six different user types:
    readers
    updaters
    owners
    unauthorized_readers
    unauthorized_updaters
    unauthorized_owners

  To select the routes, a 'routes_config_options' instance is used used.

  routes_config_options:

  As a convience a 'default_route_options' is available via 'new_route_config_options' without an options arg):
    admin_match:           route_admin_matches,
    readers:               :read_1,
    updaters:              :update_1,
    owners:                :owner_1,
    unauthorized_readers:  :read_2,
    unauthorized_updaters: :update_2,
    unauthorized_owners:   :owner_2,

  The default route_admin_matches array:
    {controller: :users,            actions: :create},
    {controller: :assignments,      actions: [:roster, :view]},
    {controller: :peer_assessment,  actions: [:create, :view]},
    {controller: :contents,         actions: [:validate, :update]},
    :phase_states,
    :phase_scores,
    #=> Plus any controller in an 'Admin' namespace

  See 'helpers/casespace/routes.rb' for the current defaults (e.g. defaults may change).
  Once a 'routes_config_options' instance is created, additional route selection criteria can be added.

Route Selection:

  co = new_route_config_options  #=> this is both a class and instance method
  co.only(engines, controllers, actions)
  co.except(engines, controllers, actions)

  The selection is done via a string 'match' and the values need to be specific enough to select the wanted route.
  Each arg can be a single value or an array but must be passed in the order specified above.
  Only the args passed will be added to the selection matching (e.g. no defaults).
  The selection matches are added 'per' call (e.g. co.only can be called multiple times to set multiple selection criteria).
  To be a match, all of the passed args (engines, controllers and actions) must match.
  The 'only' and 'except' methods are 'additive' to any existing matching criteria set in the initial options.
  'Only' matches are done before any 'except' matches.

  Examples:
    co.only :common                 #=> select only the common engine routes
    co.only :common, :users         #=> select only the common user controller routes
    co.only :common, :users, :show  #=> select only the common user controller's show route
    co.only :common, 'admin/users'  #=> select only the common admin users controller routes
    co.only [:common, :casespace]   #=> select only the common and casepsace engine routes


User Selection:

  Unlike the 'only' and 'except' methods, the 'only_users' method sets the value to the hash values.
  Any user type not in the hash are blanked.

  User values can be a single value or array of values.

  Examples:
    co = new_route_config_options(readers: :read_1, updaters: :update_1)
    co.only_users(readers: :new_reader)  #=> only run with a reader name of 'new_reader' (updaters is blanked)

Option Values:

  Option values can be set via 'co.option_key_name(value)' or 'co.option_key_name = value'.

  For non-array option values, both versions are the same.  The option key name is set to the value.

  For array option values, the versions result in different values:
    co.some_option_key(value)    #=> add the value to the existing array option key values
    co.some_option_key = value   #=> set the array option key to the value
  Examples:
    co = new_route_config_options(readers: :read_1)
    co.readers(:new_reader)   #=> options[:readers] = [:read_1, :new_reader]
    co.readers = :new_reader  #=> options[:readers] = [:new_reader]


Route:

  Each selected route config is retrieved via 'get_controller_route_configs(co)'.
  An array of Route instances are returned populated with route information such as:
    engine_routes  #=> reference the engine routes for controller tests
    action
    verb
    type
    helper  #=> the route view helper method
    controller_path
    test_it_name

  The route instance includes many other helper methods.
  See helpers/casespace/route.rb).
  Such as: member?, collection?, create?, show?, etc.

Using Module Routes and RouteModels:

  The Routes module's main method is 'send_route_request'.
  It will use RouteModels to attempt to create any models required for the route.
  When 'let(:base_model) {[recorda, recordb, etc.]}' is added in a test, if a route
  requires a model class of one of the records in the 'base_model' array, it will be used.

  RouteModels builds a model dictionary (e.g. similar to deep_copy) and sets it in the Route instance.

Changing the Dictionary and Params based on route:

  The Routes/Route instances have multiple hooks that can be used to adjust models in the
  dictionary and/or the params.

  The hooks must be defined in a class generated by concatenating:
    co.controller_helper_namespace + controller_path

  Hooks include:
    * dictionary based (before/after save)
    * params based

  A hook must accept at least one arg (the route).
  If the hook accepts two args, it will receive the route and the options for the route (the options include the params).
  The dictionary, database and params can be changed by any hook.

  IMPORTANT: When a hook is called, only the values to that point-in-time have been established.
  IMPORTANT: If the 'controller_helper_namespace' option is blank, no hooks will be called.
  IMPORTANT: The hook class must have been required to be constantized.
             One location that will be required is in the helpers e.g. helpers/ability/controllers.

  Examples (for thinkspace-common):
    co.controller_helper_namespace = 'Test::Ability::Controllers'

    module Test; module Ability; module Controllers; module Thinkspace; module Common; module Api
      class UsersController
        def setup_create_can_update_authorized(route); route.assert_unauthorized(/authentication server down/i); end
        def setup_sign_out(route);    route.assert_authorized; end
      end
      module Admin
        class UsersController
          def setup_select_can_update_unauthorized(route); route.assert_authorized; end
        end
      end
    end
    ...

  See the Routes and Route classes for a list of hooks.
