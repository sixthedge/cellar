module Test::ReadinessAssurance::Helpers::Route::SubmitIrat
extend ActiveSupport::Concern
included do

  @co = new_route_config_options(tests: get_tests)
  @co.only :casespace, :phases, :submit

  def models; @models ||= [current_phase, current_user, ownerable, assessment, record]; end
  def record; @record ||= get_response; end

  def ownerable;    current_user; end
  def current_user; @current_user ||= user; end

  def set_current_user(cu); @current_user = cu; @record = nil; @models = nil; end

  get_controller_route_configs(@co).each do |config|
    describe config.controller_class do
      before do; @routes = config.engine_routes; end
      let(:current_phase)  {irat_phase}
      let(:authable)       {current_phase}
      let(:user)           {read_1}
      let(:assessment)     {get_assessment}
      let(:ownerables)     {[read_1, read_2]}
      let(:assignment)     {get_assignment}
      # let(:print_params)   {true}
      # let(:print_json)     {true}
      # let(:debug)          {true}
      @config = config
      @action = :submit
      route   = @config.controller_action_route(@action)
      route.set_as_reader
      (@config.routes_config.options[:tests] || []).each do |t|
        t.call(route)
      end
  end; end

end; end
