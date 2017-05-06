# #
# # TEMPORARY tests to verify the new serializer options query-key matches the old model query-key.
# #
# require 'serializer_helper'
# Test::Casespace::Seed.load(config: :serializer)
# module Test; module Serializer; class CacheKeyQuery < ActionController::TestCase
#   include Controller
#   include Model
#   include Assert
#   include ModuleMethods

#   describe @spaces_controller do
#     let(:user)   {serializer_update_user}
#     describe 'space index' do
#       let(:record) {all_serializer_spaces}
#       let(:action) {:index}
#       it 'using cache_query_key method' do
#         serializer_options.cache ownerable: user
#         orig_digest = cache_digest(cache_key)
#         serializer_options.cache ownerable: user
#         serializer_options.cache_query_key name: :spaces, column: :updated_at
#         serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
#         serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
#         serializer_options.cache_query_key(name: :release_at,  maximum: :thinkspace_casespace_assignments,
#           where:  ['thinkspace_casespace_assignments.release_at < ?', Time.now],
#           column: :release_at
#         )
#         query_digest = cache_digest(cache_key)
#         assert_equal orig_digest, query_digest, '==> model and serializer options cache key digests should match'
#       end
#       it 'using cache :query_key option' do
#         serializer_options.cache ownerable: user
#         orig_digest = cache_digest(cache_key)
#         hash = {
#           ownerable: user,
#           query_key: [
#             {name: :spaces, column: :updated_at},
#             {name: :assignments, maximum: :thinkspace_casespace_assignments},
#             {name: :space_users, maximum: :thinkspace_common_space_users},
#             {name: :release_at,  maximum: :thinkspace_casespace_assignments,
#               where: ['thinkspace_casespace_assignments.release_at < ?', Time.now],
#               column: :release_at},
#           ]
#         }
#         serializer_options.cache(hash)
#         query_digest = cache_digest(cache_key)
#         assert_equal orig_digest, query_digest, '==> model and serializer options cache key digests should match'
#       end
#       it 'mixed cache query_key options' do
#         serializer_options.cache ownerable: user
#         orig_digest = cache_digest(cache_key)
#         serializer_options.cache ownerable: user, query_key: {name: :spaces, column: :updated_at}
#         serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
#         serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
#         serializer_options.cache_query_key(name: :release_at,  maximum: :thinkspace_casespace_assignments,
#           where:  ['thinkspace_casespace_assignments.release_at < ?', Time.now],
#           column: :release_at
#         )
#         query_digest = cache_digest(cache_key)
#         assert_equal orig_digest, query_digest, '==> model and serializer options cache key digests should match'
#       end
#     end  # all spaces

#     describe 'space..show' do
#       let(:record) {all_serializer_spaces.first}
#       let(:action) {:show}
#       it 'query key' do
#         serializer_options.cache ownerable: user
#         orig_digest = cache_digest(cache_key)
#         serializer_options.cache ownerable: user
#         serializer_options.cache_query_key name: :space, column: :updated_at
#         serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
#         serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
#         serializer_options.cache_query_key(name: :release_at,  maximum: :thinkspace_casespace_assignments,
#           where:  ['thinkspace_casespace_assignments.release_at < ?', Time.now],
#           column: :release_at
#         )
#         query_digest = cache_digest(cache_key)
#         assert_equal orig_digest, query_digest, '==> model and serializer options cache key digests should match'
#       end
#     end

#   end

# end; end; end
