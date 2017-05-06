require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class ModelsSpaceModule < ActionController::TestCase
  include Controller
  include Model
  include Assert
  include ModuleMethods

  describe @spaces_controller do
    let(:user)   {serializer_update_user}
    describe 'models..module..space' do
      let(:record) {all_serializer_spaces}
      let(:action) {:index}

      it 'with module ability..without metadata' do
        serializer_options.include_module_ability spaces_module_ability_hash
        json = serialize
        assert_with_ability_without_metadata(json)
        assert_spaces_module_ability(json)
      end

      it 'with module ability..with ability include and actions..without metadata' do
        serializer_options.include_ability read: true
        serializer_options.ability_actions :update
        serializer_options.include_module_ability spaces_module_ability_hash
        json = serialize
        assert_with_ability_without_metadata(json)
        array = assert_spaces_module_ability(json)
        assert_equal 3, array.length, 'includes space module ability and space record abilities'
        assert_ability_json(json, record, user, {read: true, update: true})
      end

      it 'with module metadata..without ability' do
        serializer_options.include_module_metadata spaces_module_metadata_hash
        json = serialize
        assert_without_ability_with_metadata(json)
        assert_spaces_module_metadata(json)
      end

      it 'with module metadata..with metadata include..without ability' do
        serializer_options.include_metadata
        serializer_options.include_module_metadata spaces_module_metadata_hash
        json = serialize
        assert_without_ability_with_metadata(json)
        array = assert_spaces_module_metadata(json)
        assert_equal 3, array.length, 'includes space module metadata and space record metadata'
        assert_metadata_json(json, record, user, space_metadata_value, except: :next_due_at)
      end

      it 'with module ability..with module metadata' do
        serializer_options.include_module_ability  spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash
        json = serialize
        assert_spaces_module_ability(json)
        assert_spaces_module_metadata(json)
      end

      it 'cache module ability..no ownerable' do
        serializer_options.include_module_ability spaces_module_ability_hash
        serializer_options.cache
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_ability spaces_module_ability_hash
        json = controller_json
        controller_after_json(json)
        assert_spaces_module_ability(json)
      end

      it 'cache..module ability..ownerable' do
        serializer_options.include_module_ability spaces_module_ability_hash
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        json = controller_json
        assert_with_ability_without_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_ability spaces_module_ability_hash
        json = controller_json
        assert_spaces_module_ability(json)
      end

      it 'cache..module metadata..no ownerable' do
        serializer_options.include_module_metadata spaces_module_metadata_hash
        serializer_options.cache
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_metadata spaces_module_metadata_hash
        json = controller_json
        controller_after_json(json)
        assert_spaces_module_metadata(json)
      end

      it 'cache..module metadata..ownerable' do
        serializer_options.include_module_metadata spaces_module_metadata_hash
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_with_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_metadata spaces_module_metadata_hash
        json = controller_json
        assert_spaces_module_metadata(json)
      end

      it 'cache..module_ability..module metadata..no ownerable' do
        serializer_options.include_module_ability spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash
        serializer_options.cache
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_ability spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash
        json = controller_json
        assert_without_ability_without_metadata(json)
        controller_after_json(json)
        assert_spaces_module_ability(json)
        assert_spaces_module_metadata(json)
      end

      it 'cache..module_ability..module metadata..ownerable' do
        serializer_options.include_module_ability spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        json = controller_json
        assert_with_ability_with_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_ability spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash
        json = controller_json
        assert_spaces_module_ability(json)
        assert_spaces_module_metadata(json)
      end

      # ### Module hash has cache:false

      it 'cache..module_ability..module metadata..ownerable..metadata cache:false..ownerable' do
        serializer_options.include_module_ability  spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash.merge(cache: false)
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        json = controller_json
        assert_with_ability_without_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_ability  spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash.merge(cache: false)
        json = controller_json
        controller_after_json(json)
        array = assert_spaces_module_ability(json)
        assert_equal 1, array.length, 'only ability module data and not duplicated'
        array = assert_spaces_module_metadata(json)
        assert_equal 1, array.length, 'only metadata module data and not duplicated'
      end

      it 'cache..module_ability..module metadata..ownerable..abiilty cache:false..ownerable' do
        serializer_options.include_module_ability  spaces_module_ability_hash.merge(cache: false)
        serializer_options.include_module_metadata spaces_module_metadata_hash
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_with_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_ability  spaces_module_ability_hash.merge(cache: false)
        serializer_options.include_module_metadata spaces_module_metadata_hash
        json = controller_json
        controller_after_json(json)
        array = assert_spaces_module_ability(json)
        assert_equal 1, array.length, 'only ability module data and not duplicated'
        array = assert_spaces_module_metadata(json)
        assert_equal 1, array.length, 'only metadata module data and not duplicated'
      end

      # No-ownerable is the same as ability and metadata with cache:false.

      it 'cache..module_ability..module metadata..abiilty and metadata cache:false..no ownerable' do
        serializer_options.include_module_ability  spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash
        serializer_options.cache
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_ability  spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash
        json = controller_json
        assert_without_ability_without_metadata(json)
        controller_after_json(json)
        array = assert_spaces_module_ability(json)
        assert_equal 1, array.length, 'only ability module data and not duplicated'
        array = assert_spaces_module_metadata(json)
        assert_equal 1, array.length, 'only metadata module data and not duplicated'
      end

      it 'cache..module_ability..module metadata..abiilty and metadata cache:false..no ownerable' do
        serializer_options.include_module_ability  spaces_module_ability_hash.merge(cache: false)
        serializer_options.include_module_metadata spaces_module_metadata_hash.merge(cache: false)
        serializer_options.cache
        set_space_cache_serializer_options
        json = controller_json
        assert_without_ability_without_metadata(json)
        serializer_options.clear_collect_data
        serializer_options.include_module_ability  spaces_module_ability_hash.merge(cache: false)
        serializer_options.include_module_metadata spaces_module_metadata_hash.merge(cache: false)
        json = controller_json
        assert_without_ability_without_metadata(json)
        controller_after_json(json)
        array = assert_spaces_module_ability(json)
        assert_equal 1, array.length, 'only ability module data and not duplicated'
        array = assert_spaces_module_metadata(json)
        assert_equal 1, array.length, 'only metadata module data and not duplicated'
      end

      # Method default.

      it 'module_ability..module metadata..no ownerable..default method' do
        serializer_options.include_module_ability  module: ability_module
        serializer_options.include_module_metadata module: metadata_module
        json = serialize
        assert_with_ability_with_metadata(json)
        array = assert_spaces_module_ability(json)
        assert_equal 1, array.length, 'only ability module data and not duplicated'
        array = assert_spaces_module_metadata(json)
        assert_equal 1, array.length, 'only metadata module data and not duplicated'
      end

      # ID override.

      it 'module_ability..module metadata..no ownerable..id override' do
        serializer_options.include_module_ability  spaces_module_ability_hash.merge(id: :ability_id)
        serializer_options.include_module_metadata spaces_module_metadata_hash.merge(id: :metadata_id)
        json = serialize
        assert_with_ability_with_metadata(json)
        array = assert_spaces_module_ability(json)
        assert_equal 1, array.length, 'only ability module data and not duplicated'
        array.first[:id] = :ability_id
        array = assert_spaces_module_metadata(json)
        assert_equal 1, array.length, 'only metadata module data and not duplicated'
        array.first[:id] = :metadata_id
      end

      # Raise Errors.

      it 'module..blank' do
        e = assert_raises(RuntimeError) {serializer_options.include_module_metadata(id: :metadata_id)}
        assert_match(/module is blank/i, e.to_s)
      end

      it 'module..not a module' do
        e = assert_raises(RuntimeError) {serializer_options.include_module_metadata(module: :not_a_module)}
        assert_match(/not a module/i, e.to_s)
      end

      it 'module..bad method' do
        e = assert_raises(RuntimeError) {serializer_options.include_module_metadata(spaces_module_metadata_hash.merge(method: :bad_method))}
        assert_match(/not respond to method/i, e.to_s)
      end

      it 'module..duplicate id' do
        serializer_options.include_module_metadata spaces_module_metadata_hash
        e = assert_raises(RuntimeError) {serializer_options.include_module_metadata(spaces_module_metadata_hash)}
        assert_match(/module id.*duplicate/i, e.to_s)
      end

    end
  end

end; end; end
