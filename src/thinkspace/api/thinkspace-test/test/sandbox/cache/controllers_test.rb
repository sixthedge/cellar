# ########################################################################################################## #
# ### NEED TO ADD ASSERT MATCH VALUES FOR TESTS (otherwise can use to print keys for manual inspection). ### #
# ########################################################################################################## #

# require 'sandbox_helper'
# require 'serializer_helper'
# module Test; module Cache; class SandboxControllersTest < ActionController::TestCase
#   include ::Test::Serializer::Controller
#   include Sandbox::Helpers::All

#   class SpaceSerializerOptions;      include ::Thinkspace::Common::Concerns::SerializerOptions::Spaces; end
#   class AssignmentSerializerOptions; include ::Thinkspace::Casespace::Concerns::SerializerOptions::Assignments; end
#   class PhaseSerializerOptions;      include ::Thinkspace::Casespace::Concerns::SerializerOptions::Phases; end

#   describe @spaces_controller do
#     let(:user)   {read_1}
#     let(:action) {:index}
#     describe 'space index' do
#       it 'serializer options' do
#         verify_test_environment_controller_cache
#         # create_not_sandbox_models
#         current_user(user)
#         action_name(action)
#         spaces = space_class.accessible_by(current_ability, :read)
#         SpaceSerializerOptions.new.index(serializer_options)
#         key = @controller.send(:controller_cache_key, spaces, serializer_options.cache_options)
#         print_spaces_cache_key(key, "Sandbox Space##{action} Cache Key")
#         # json   = @controller.controller_as_json(spaces)
#         # pp json
#         # TODO: add the correct assert_match values.
#         # assert_match /.*assignment\/#{cache_timestamp(record)}/, key, '==> serializer options cache key does not include assignment timestamp'
#         # assert_match /.*phases\/#{phase_timestamp}/, key, '==> serializer options cache key does not include phase timestamp'
#         # assert_match /.*phase_states\/#{@state_timestamp}/, key, '==> serializer options cache key does not include state timestamp'
#         # assert_match /.*phase_scores\/#{@score_timestamp}/, key, '==> serializer options cache key does not include score timestamp'
#       end
#     end
#   end

#   describe @assignments_controller do
#     let(:user)   {read_1}
#     let(:action) {:phase_states}
#     describe 'assignments phase states' do
#       it 'serializer options' do
#         verify_test_environment_controller_cache
#         current_user(user)
#         action_name(action)
#         params_ownerable(user)
#         set_instance_var(sandbox_assignment)
#         AssignmentSerializerOptions.new.phase_states(serializer_options)
#         key = @controller.send(:controller_cache_key, sandbox_assignment, serializer_options.cache_options)
#         print_assignment_cache_key(key, "Sandbox Assignment##{action} Cache Key")
#         # json = @controller.controller_as_json(sandbox_assignment)
#         # pp json
#         # TODO: add the correct assert_match values.
#         # assert_match /.*assignment\/#{cache_timestamp(record)}/, key, '==> serializer options cache key does not include assignment timestamp'
#         # assert_match /.*phases\/#{phase_timestamp}/, key, '==> serializer options cache key does not include phase timestamp'
#         # assert_match /.*phase_states\/#{@state_timestamp}/, key, '==> serializer options cache key does not include state timestamp'
#         # assert_match /.*phase_scores\/#{@score_timestamp}/, key, '==> serializer options cache key does not include score timestamp'
#       end
#     end
#   end

#   describe @phases_controller do
#     let(:user)   {read_1}
#     let(:action) {:load}
#     describe 'phase load' do
#       it 'serializer options' do
#         verify_test_environment_controller_cache
#         current_user(user)
#         action_name(action)
#         params_ownerable(user)
#         authable_ability
#         phase = read_1_sandbox_phase
#         set_instance_var(phase)
#         PhaseSerializerOptions.new.load(serializer_options)
#         key = @controller.send(:controller_cache_key, phase, serializer_options.cache_options)
#         print_phase_cache_key(key, "Sandbox Phase##{action} Cache Key")
#         # json = @controller.controller_as_json(phase)
#         # pp json
#         # TODO: add the correct assert_match values.
#         # assert_match /.*assignment\/#{cache_timestamp(record)}/, key, '==> serializer options cache key does not include assignment timestamp'
#         # assert_match /.*phases\/#{phase_timestamp}/, key, '==> serializer options cache key does not include phase timestamp'
#         # assert_match /.*phase_states\/#{@state_timestamp}/, key, '==> serializer options cache key does not include state timestamp'
#         # assert_match /.*phase_scores\/#{@score_timestamp}/, key, '==> serializer options cache key does not include score timestamp'
#       end
#     end
#   end

# end; end; end
