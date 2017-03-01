require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class ModelsSpaceCache < ActionController::TestCase
  include Controller
  include Model
  include Assert


# pp json
# puts "\n\nKEYS=#{serializer_options.collect_keys.inspect}"
# puts "\n\nONLY KEYS=#{serializer_options.collect_only_keys.inspect}"
# puts "\n\nCACHE DATA=#{serializer_options.collect_data.inspect}"


  describe @spaces_controller do
    let(:user)   {serializer_update_user}
    describe 'models..cache..space' do
      let(:record) {all_serializer_spaces}
      let(:action) {:index}

      # include ability
      it 'with ability..without metadata..no ownerable' do
        serializer_options.include_ability read: true
        serializer_options.cache
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        json = controller_after_json(json)
        assert_with_ability_without_metadata(json)
      end
      it 'with ability..without metadata..ownerable' do
        serializer_options.include_ability read: true
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        json = controller_json
        assert_with_ability_without_metadata(json)
        json = controller_after_json(json)
        assert_with_ability_without_metadata(json)
      end

      # ability actions
      it 'with ability actions..without metadata..no ownerable' do
        serializer_options.ability_actions :update
        serializer_options.cache
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        json = controller_after_json(json)
        assert_with_ability_without_metadata(json)
      end
      it 'with ability actions..without metadata..ownerable' do
        serializer_options.ability_actions :update
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        json = controller_json
        assert_with_ability_without_metadata(json)
        json = controller_after_json(json)
        assert_with_ability_without_metadata(json)
      end

      # include metadata
      it 'without ability..with metadata..no ownerable' do
        serializer_options.include_metadata
        serializer_options.cache
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        json = controller_after_json(json)
        assert_without_ability_with_metadata(json)
      end
      it 'without ability..with metadata..ownerable' do
        serializer_options.include_metadata
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_with_metadata(json)
        json = controller_after_json(json)
        assert_without_ability_with_metadata(json)
      end

      # ability only (other options should not change return json)
      it 'ability only..metadata..no ownerable' do
        serializer_options.include_metadata
        serializer_options.include_ability read: true
        serializer_options.cache
        set_space_cache_serializer_options
        serializer_options.ability_only
        assert_only_ability(serialize)
      end

      # metadata only (other options should not change return json)
      it 'metadata only..metadata..no ownerable' do
        serializer_options.include_metadata
        serializer_options.include_ability read: true
        serializer_options.cache
        set_space_cache_serializer_options
        serializer_options.metadata_only
        assert_only_metadata(serialize)
      end

      # get cached json and adds ability to final json
      it 'adds ability..no ownerable' do
        serializer_options.include_ability read: true
        serializer_options.cache
        set_space_cache_serializer_options
        cache_json = controller_json
        assert_without_ability_without_metadata(cache_json)
        serializer_options.clear_collect_data
        json = controller_json
        controller_after_json(json)
        assert_with_ability_without_metadata(json)
      end

      # get cached json that includes ability
      it 'includes ability..ownerable' do
        serializer_options.include_ability read: true
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        cache_json = controller_json
        assert_with_ability_without_metadata(cache_json)
        serializer_options.clear_collect_data
        json = controller_json
        assert_with_ability_without_metadata(json)
        assert_json_equal(cache_json, json)
      end

      # get cached json and adds metadata to final json
      it 'adds metadata..no ownerable' do
        serializer_options.include_metadata
        serializer_options.cache
        set_space_cache_serializer_options
        cache_json = controller_json
        assert_without_ability_without_metadata(cache_json)
        serializer_options.clear_collect_data
        json = controller_json
        assert_without_ability_without_metadata(json)  # cache json
        controller_after_json(json)
        assert_without_ability_with_metadata(json)
      end

      # get cached json that includes metadata
      it 'includes metadata..ownerable' do
        serializer_options.include_metadata
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        cache_json = controller_json
        assert_without_ability_with_metadata(cache_json)
        serializer_options.clear_collect_data
        json = controller_json
        assert_without_ability_with_metadata(json)
        assert_json_equal(cache_json, json)
      end

      # get cached json and adds ability and metadata to final json
      it 'adds ability and metadata..no ownerable' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache
        set_space_cache_serializer_options
        cache_json = controller_json
        assert_without_ability_without_metadata(cache_json)
        serializer_options.clear_collect_data
        json = controller_json
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
      end

      # get cached json that includes ability and metadata
      it 'includes ability and metadata..ownerable' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        cache_json = controller_json
        assert_with_ability_with_metadata(cache_json)
        serializer_options.clear_collect_data
        json = controller_json
        assert_with_ability_with_metadata(json)
        assert_json_equal(cache_json, json)
      end

      # Test cache options -> ability:false and metadata:false

      it 'ownerable..metadata:false' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache ownerable: user, metadata: false
        set_space_cache_serializer_options
        json = controller_json
        assert_with_ability_without_metadata(json)
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
      end

      it 'ownerable..ability:false' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache ownerable: user, ability: false
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_with_metadata(json)
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
      end

      it 'ownerable..ability:false..metadata:false' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache ownerable: user, ability: false, metadata: false
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
      end

      it 'from cache..ownerable..metadata:false' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache ownerable: user, metadata: false
        set_space_cache_serializer_options
        cache_json = controller_json
        assert_with_ability_without_metadata(cache_json)
        controller_after_json(cache_json)
        assert_with_ability_with_metadata(cache_json)
        serializer_options.clear_collect_data
        json = controller_json
        assert_with_ability_without_metadata(json)  # cache json
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
        assert_json_equal(cache_json, json)
      end

      it 'from cache..ownerable..ability:false' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache ownerable: user, ability: false
        set_space_cache_serializer_options
        cache_json = controller_json
        assert_without_ability_with_metadata(cache_json)
        controller_after_json(cache_json)
        assert_with_ability_with_metadata(cache_json)
        serializer_options.clear_collect_data
        json = controller_json
        assert_without_ability_with_metadata(json)
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
        assert_json_equal(cache_json, json)
      end

      it 'from cache..ownerable..ability:false..metadata:false' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache ownerable: user, ability: false, metadata: false
        set_space_cache_serializer_options
        cache_json = controller_json
        assert_without_ability_without_metadata(cache_json)
        controller_after_json(cache_json)
        assert_with_ability_with_metadata(cache_json)
        serializer_options.clear_collect_data
        json = controller_json
        assert_without_ability_without_metadata(json)
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
        assert_json_equal(cache_json, json)
      end

      # Without an ownerable, ability and metadata are not cached regardless of ability:false and/or metadata:false.

      it 'no ownerable..metadata:false' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache metadata: false
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
      end

      it 'no ownerable..ability:false' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache ability: false
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
      end

      it 'no ownerable..ability:false..metadata:false' do
        serializer_options.include_ability read: true
        serializer_options.include_metadata
        serializer_options.cache ability: false, metadata: false
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        controller_after_json(json)
        assert_with_ability_with_metadata(json)
      end

    end
  end

end; end; end
