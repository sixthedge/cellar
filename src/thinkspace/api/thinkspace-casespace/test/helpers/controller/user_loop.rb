module Test; module Controller; module UserLoop

  extend ActiveSupport::Concern
  included do

  def self.get_mod(mod); "::Test::Controller::#{mod}".constantize; end
  def self.run_test_it(test_it); [test_it].flatten.compact.map {|ti| self.instance_eval(&ti)}; end

  if (readers = @config.readers).present?
    readers.each do |username|
      route = @config.controller_action_route(@action)
      route.set_as_reader
      mod = @mod; before_test_it = @test_it_before; after_test_it  = @test_it_after || @test_it
      describe "..#{route.user_type}#{route.test_it_name}.." do
        @username = username
        @route    = route
        before do; @route = route; end
        let(:user)      {get_user(username)}
        let(:ownerable) {user}
        let(:models)    {base_models + [user]}
        run_test_it(before_test_it) if before_test_it.present?
        class_eval do; include get_mod(mod); end  if mod.present?
        run_test_it(after_test_it) if after_test_it.present?
      end
    end
  end

  if (updaters = @config.updaters).present?
    updaters.each do |username|
      route = @config.controller_action_route(@action)
      route.set_as_updater
      mod = @mod; before_test_it = @test_it_before; after_test_it  = @test_it_after || @test_it
      describe "..#{route.user_type}#{route.test_it_name}.." do
        @username = username
        @route    = route
        before do; @route = route; end
        let(:user)      {get_user(username)}
        let(:ownerable) {user}
        let(:models)    {base_models + [user]}
        run_test_it(before_test_it) if before_test_it.present?
        class_eval do; include get_mod(mod); end  if mod.present?
        run_test_it(after_test_it) if after_test_it.present?
      end
    end
  end

  if (owners = @config.owners).present?
    owners.each do |username|
      route = @config.controller_action_route(@action)
      route.set_as_updater
      mod = @mod; before_test_it = @test_it_before; after_test_it  = @test_it_after || @test_it
      describe "..#{route.user_type}#{route.test_it_name}.." do
        @username = username
        @route    = route
        before do; @route = route; end
        let(:user)      {get_user(username)}
        let(:ownerable) {user}
        let(:models)    {base_models + [user]}
        run_test_it(before_test_it) if before_test_it.present?
        class_eval do; include get_mod(mod); end  if mod.present?
        run_test_it(after_test_it) if after_test_it.present?
      end
    end
  end

  @config.unauthorized_user_types.each do |user_type|
    if (unauthorized = @config.send(user_type)).present?
      route = @config.controller_action_route(@action)
      route.send "set_as_#{user_type.to_s.singularize}"
      mod = @mod; test_it = @test_it
      describe "..#{route.user_type}#{route.test_it_name}.." do
        before do; @route = route; end
        unauthorized.each do |username|
          let(:user)      {get_user(username)}
          let(:ownerable) {user}
          let(:models)    {base_models + [user]}
          it "..#{username}#{route.test_it_name}" do
            hash = send_route_request
            assert_route_unauthorized(@route, hash)
          end
        end
      end
    end
  end

end; end; end; end
