# require 'serializer_helper'
# Test::Casespace::Seed.load(config: :serializer)
# module Test; module Serializer; class CacheKeyQuery < ActionController::TestCase
#   include Controller
#   include Model
#   include Assert
#   include ModuleMethods

#   def set_cache_options
#     serializer_options.cache ownerable: user
#     # updated_at
#     serializer_options.cache_query_key name: :spaces  # defaults: method=:minimum and column=:updated_at
#     serializer_options.cache_query_key name: :spaces, method: :maximum, column: :updated_at
#     serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
#     serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
#     serializer_options.cache_query_key name: :spaces_min, method: :minimum
#     # where
#     serializer_options.cache_query_key(
#       name:    :release_at,
#       maximum: :thinkspace_casespace_assignments,
#       where:   ['thinkspace_casespace_assignments.release_at < ?', Time.now],
#       column:  :release_at
#     )
#     # count
#     serializer_options.cache_query_key name: :space_users_count, count: :thinkspace_common_space_users, distinct: :user_id
#     serializer_options.cache_query_key name: :assignments_count, count: :thinkspace_casespace_assignments
#     # pluck
#     serializer_options.cache_query_key name: :space_user_roles, pluck: :thinkspace_common_space_users, column: :role, unique: true
#     serializer_options.cache_query_key name: :spaces_ids, method: :pluck, column: :id
#     # scope
#     if action == :index
#       serializer_options.cache_query_key name: :active_spaces, scope: :scope_active
#       serializer_options.cache_query_key name: :active_spaces_ids, method: :pluck, column: :id, scope: :scope_active
#     end
#   end

#   describe @spaces_controller do
#     let(:user)   {serializer_update_user}

#     describe 'print space index' do
#       let(:record) {all_serializer_spaces}
#       let(:action) {:index}
#       it 'various options' do
#         set_cache_options
#         serializer_options.cache_query_key name: :spaces_count
#         print_cache_key('Space index various options')
#       end
#     end

#     describe 'print space show' do
#       let(:record) {serializer_space}
#       let(:action) {:show}
#       it 'various options' do
#         set_cache_options
#         print_cache_key('Space show various options')
#       end
#     end

#   end

# end; end; end
