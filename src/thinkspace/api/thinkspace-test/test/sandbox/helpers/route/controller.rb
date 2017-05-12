module Test::Sandbox::Helpers::Route::Controller
extend ActiveSupport::Concern
included do

  def models;       [current_user, record]; end
  def current_user; user; end
  def ownerable;    current_user; end

  get_controller_route_configs(@co).each do |config|
    describe config.controller_class do
      before do; @routes = config.engine_routes; end
      let(:params)         {get_let_value(:proc_params)  || Hash.new}
      let(:print_params)   {get_let_value(:debug_params) || false}
      let(:print_json)     {get_let_value(:debug_json)   || false}
      # let(:print_params)   {true} # global scope
      # let(:print_json)     {true} # global scope
      # let(:debug)          {true} # global scope
      @config = config
      @action = @config.routes_config.options[:test_action]
      route   = @config.controller_action_route(@action)
      route.set_as_reader
      (@config.routes_config.options[:tests] || []).each do |t|
        t.call(route)
      end
  end; end

end; end
