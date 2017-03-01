module Test::Ability::TestRoutes
  extend ActiveSupport::Concern
  included do

    if (readers = @config.readers).present?
      @config.controller_routes.each do |route|
        route.set_as_reader
        route.setup
        describe "..#{route.user_type}.." do
          before do; @route = route; end
          readers.each do |username|
            let(:user)      {get_user(username)}
            let(:ownerable) {user}
            let(:models)    {base_models + [user, get_space_user(space, user)]}
            it "..#{username}#{route.test_it_name}" do
              assert_sign_in(method(:send_route_request))             && return if @route.sign_in?
              assert_route_error(method(:send_route_request), @route) && return if @route.assert_raise_error?
              hash = send_route_request
              (@route.admin? || @route.assert_unauthorized?) ? assert_route_unauthorized(@route, hash) : assert_route_authorized(@route, hash)
            end
          end
        end
      end
    end

    if (updaters = @config.updaters).present?
      @config.controller_routes.each do |route|
        route.set_as_updater
        route.setup
        describe "..#{route.user_type}.." do
          before do; @route = route; end
          updaters.each do |username|
            let(:user)      {get_user(username)}
            let(:ownerable) {user}
            let(:models)    {base_models + [user, get_space_user(space, user)]}
            it "..#{username}#{route.test_it_name}" do
              assert_sign_in(method(:send_route_request))             && return if @route.sign_in?
              assert_route_error(method(:send_route_request), @route) && return if @route.assert_raise_error?
              hash = send_route_request
              @route.assert_unauthorized? ? assert_route_unauthorized(@route, hash) : assert_route_authorized(@route, hash)
            end
          end
        end
      end
    end

    if (owners = @config.owners).present?
      @config.controller_routes.each do |route|
        route.set_as_owner
        route.setup
        describe "..#{route.user_type}.." do
          before do; @route = route; end
          owners.each do |username|
            let(:user)      {get_user(username)}
            let(:ownerable) {user}
            let(:models)    {base_models + [user, get_space_user(space, user)]}
            it "..#{username}#{route.test_it_name}" do
              assert_sign_in(method(:send_route_request))             && return if @route.sign_in?
              assert_route_error(method(:send_route_request), @route) && return if @route.assert_raise_error?
              hash = send_route_request
              @route.assert_unauthorized? ? assert_route_unauthorized(@route, hash) : assert_route_authorized(@route, hash)
            end
          end
        end
      end
    end

    @config.unauthorized_user_types.each do |user_type|
      if (unauthorized = @config.send(user_type)).present?
        @config.controller_routes.each do |route|
          route.send "set_as_#{user_type.to_s.singularize}"
          route.setup
          describe "..#{route.user_type}.." do
            before do; @route = route; end
            unauthorized.each do |username|
              let(:user)      {get_user(username)}
              let(:ownerable) {user}
              let(:models)    {base_models + [user]}
              it "..#{username}#{route.test_it_name}" do
                assert_sign_in method(:send_route_request) && return  if @route.sign_in?
                assert_route_error(method(:send_route_request), @route) && return if @route.assert_raise_error?
                begin
                  hash = send_route_request
                  @route.assert_authorized? ? assert_route_authorized(@route, hash) : assert_route_unauthorized(@route, hash)
                rescue record_not_found_error => e
                  assert_equal true, true  # indicate an assertion was done e.g. raised error == unauthorized
                end
              end
            end
          end
        end
      end
    end

  end # included
end
