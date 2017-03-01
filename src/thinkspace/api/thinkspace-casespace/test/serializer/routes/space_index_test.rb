require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class RoutesSpaceIndex < ActionController::TestCase
  include Casespace::All
  include Controller
  include Model
  include Assert

  co = new_route_config_options
  co.only :common, :spaces, :index
  get_controller_route_configs(co).each do |config|
    describe config.controller_class do
      before do; @routes = config.engine_routes; end
        let(:space)        {serializer_space}
        let(:assignment)   {serializer_assignment}
        let(:phase)        {serializer_phase}
        let(:user)         {serializer_update_user}
        let(:authable)     {phase}
        let(:ownerable)    {user}
        let(:models)       {serializer_models}
      config.controller_routes.each do |route|
        describe 'spaces' do
          before do; @route = route; end
          it "index" do
            json = send_route_request
            assert_with_ability_with_metadata(json)
          end
        end
      end
    end
  end

end; end; end
