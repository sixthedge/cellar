require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class CacheKeyQueryOptions < ActionController::TestCase
  include Controller
  include Model
  include Assert
  include ModuleMethods

  def expect_space_index_key
    query_key = []
    expect_space_index_base(query_key)
    expect_space_index_query_key(query_key)
    build_cache_query_key(query_key).join('/')
  end

  def expect_space_index_base(query_key)
    query_key.push 'thinkspace/common/api/spaces_controller'
    query_key.push action
  end

  def expect_space_index_query_key(query_key)
    scope = record
    query_key.push :spaces
    query_key.push scope.dup.maximum(:updated_at)
    query_key.push :assignments
    query_key.push scope.dup.joins(:thinkspace_casespace_assignments).maximum('thinkspace_casespace_assignments.updated_at')
    query_key.push :space_users
    query_key.push scope.dup.joins(:thinkspace_common_space_users).maximum('thinkspace_common_space_users.updated_at')
    query_key.push :release_at
    query_key.push scope.dup.joins(:thinkspace_casespace_assignments).where('thinkspace_casespace_assignments.release_at < ?', Time.now).maximum('thinkspace_casespace_assignments.release_at')
  end

  def expect_space_show_key
    query_key = []
    query_key.push 'thinkspace/common/api/spaces_controller'
    query_key.push action
    query_key.push record.id
    query_key.push :spaces
    query_key.push record.updated_at
    query_key.push :assignments
    query_key.push record.thinkspace_casespace_assignments.maximum('thinkspace_casespace_assignments.updated_at')
    query_key.push :space_users
    query_key.push record.thinkspace_common_space_users.maximum('thinkspace_common_space_users.updated_at')
    query_key.push :release_at
    query_key.push record.thinkspace_casespace_assignments.where('thinkspace_casespace_assignments.release_at < ?', Time.now).maximum('thinkspace_casespace_assignments.release_at')
    build_cache_query_key(query_key).join('/')
  end

  def it_message(ek, ak)
    message  = ">>> model and serializer options cache key digests should match\n"
    message += "    Expect key   : #{ek.inspect}\n"
    message += "    Actual key   : #{ak.inspect}\n"
    message += "\n"
    message
  end

  def assert_space_index_digest
    expect_key    = expect_space_index_key
    expect_digest = cache_digest(expect_key)
    actual_key    = cache_key
    actual_digest = cache_digest(actual_key)
    assert_equal expect_digest, actual_digest, it_message(expect_key, actual_key)
  end

  def assert_space_show_digest
    expect_key    = expect_space_show_key
    expect_digest = cache_digest(expect_key)
    actual_key    = cache_key
    actual_digest = cache_digest(actual_key)
    assert_equal expect_digest, actual_digest, it_message(expect_key, actual_key)
  end

  def release_at_hash
    {
      name:    :release_at,
      maximum: :thinkspace_casespace_assignments,
      where:   ['thinkspace_casespace_assignments.release_at < ?', Time.now],
      column:  :release_at
    }
  end

  describe @spaces_controller do
    let(:user)   {serializer_update_user}

    describe 'space index' do
      let(:record) {all_serializer_spaces}
      let(:action) {:index}

      it 'using only cache_query_key method' do
        serializer_options.cache ownerable: user
        serializer_options.cache_query_key name: :spaces, column: :updated_at
        serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
        serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
        serializer_options.cache_query_key release_at_hash
        assert_space_index_digest
      end

      it 'using only cache(query_key: {}) option' do
        query_key = [
          {name: :spaces, column: :updated_at},
          {name: :assignments, maximum: :thinkspace_casespace_assignments},
          {name: :space_users, maximum: :thinkspace_common_space_users},
          release_at_hash,
        ]
        serializer_options.cache ownerable: user, query_key: query_key
        assert_space_index_digest
      end

      it 'mixed cache query_key method and options' do
        serializer_options.cache ownerable: user, query_key: {name: :spaces, column: :updated_at}
        serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
        serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
        serializer_options.cache_query_key release_at_hash
        assert_space_index_digest
      end

      it 'mixed cache query_key method and options array' do
        serializer_options.cache ownerable: user, query_key: [{name: :spaces, column: :updated_at}, {name: :assignments, maximum: :thinkspace_casespace_assignments}]
        serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
        serializer_options.cache_query_key release_at_hash
        assert_space_index_digest
      end

    end  # space index

    describe 'space..show' do
      let(:record) {serializer_space}
      let(:action) {:show}
      it 'query key' do
        serializer_options.cache ownerable: user
        serializer_options.cache_query_key name: :spaces, column: :updated_at
        serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
        serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
        serializer_options.cache_query_key release_at_hash
        assert_space_show_digest
      end
    end # space show

    describe 'space index both cache query key..plus..model query key' do
      let(:record) {all_serializer_spaces}
      let(:action) {:index}
      it 'model_query_key:true' do
        serializer_options.cache ownerable: user, model_query_key: true
        serializer_options.cache_query_key name: :spaces, column: :updated_at
        serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
        serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
        serializer_options.cache_query_key release_at_hash
        e = assert_raises(cache_error_class) {cache_key}
        assert_match /.*model does not respond to.*method/i, e.to_s, 'Raise error trying to run model method'
      end
    end

    # # ### Only applies if space model has the 'totem_cache_query_key_index' method.
    # describe 'space index both cache query key..plus..model query key' do
    #   let(:record) {all_serializer_spaces}
    #   let(:action) {:index}
    #   it 'model_query_key:true' do
    #     serializer_options.cache ownerable: user, model_query_key: true
    #     serializer_options.cache_query_key name: :spaces, column: :updated_at
    #     serializer_options.cache_query_key name: :assignments, maximum: :thinkspace_casespace_assignments
    #     serializer_options.cache_query_key name: :space_users, maximum: :thinkspace_common_space_users
    #     serializer_options.cache_query_key release_at_hash
    #     query_key = []
    #     expect_space_index_base(query_key)
    #     expect_space_index_query_key(query_key)
    #     expect_space_index_query_key(query_key)
    #     expect_key    = build_cache_query_key(query_key).join('/')
    #     expect_digest = cache_digest(expect_key)
    #     actual_key    = cache_key
    #     actual_digest = cache_digest(actual_key)
    #     assert_equal expect_digest, actual_digest, it_message(expect_key, actual_key)
    #   end
    # end

    describe 'space..show..instance var' do
      let(:record) {serializer_space}
      let(:action) {:show}
      it 'execption if instance var blank' do
        serializer_options.cache ownerable: user, instance_var: :testabc
        serializer_options.cache_query_key name: :spaces
        e = assert_raises(cache_error_class) {cache_key}
        assert_match /.*testabc.*blank/, e.to_s, 'Instance var blank'
      end
      it 'uses instance var' do
        space = all_serializer_spaces.find {|s| s.id != record.id}
        @controller.instance_variable_set(:@testabc, space)
        serializer_options.cache ownerable: user, instance_var: :testabc
        serializer_options.cache_query_key name: :space_id, column: :id
        key = cache_key
        assert_match /.*space_id\/#{space.id}\//, key
      end
    end

  end

end; end; end
