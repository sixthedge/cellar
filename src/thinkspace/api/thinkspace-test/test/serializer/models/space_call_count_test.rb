require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class ModelsSpaceCallCount < ActionController::TestCase
  include Controller
  include Model
  include Assert
  include ModuleMethods
  include Mocks

  def set_serializer_options
    serializer_options.ability_actions :update, :destroy
    serializer_options.include_ability read: true
    serializer_options.include_module_ability  spaces_module_ability_hash
    serializer_options.include_metadata
    serializer_options.include_module_metadata spaces_module_metadata_hash
  end

  describe @spaces_controller do
    let(:user)   {serializer_update_user}
    let(:record) {all_serializer_spaces}
    let(:action) {:index}

    describe 'collect_module_data_for' do
      let(:stub_method) {:collect_module_data_for}

      it 'ability..metadata' do
        set_serializer_options
        mock = mock_counter(2) # :ability and :metadata
        serializer_options.stub stub_method, mock do
          json = serialize
        end
        mock.verify
      end

      it 'cache..with ability..with metadata..ownerable' do
        set_serializer_options
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        mock = mock_for_keys(:ability, :metadata)
        serializer_options.stub stub_method, mock do
          json = serialize
        end
        mock.verify
        serializer_options.clear_collect_data
        serializer_options.clear_collect_cache_key_options
        set_serializer_options
        mock = mock_counter(0)  # all from cache
        serializer_options.stub stub_method, mock do
          json = serialize
        end
      end

      it 'cache..with ability..without metadata..ownerable' do
        serializer_options.ability_actions :update, :destroy
        serializer_options.include_ability read: true
        serializer_options.include_module_ability  spaces_module_ability_hash
        serializer_options.include_metadata
        serializer_options.include_module_metadata spaces_module_metadata_hash.merge(cache: false)
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        mock = mock_for_keys(:ability, :metadata)
        serializer_options.stub stub_method, mock do
          json = serialize
        end
        mock.verify
        serializer_options.init_collect_data
        serializer_options.ability_actions :update, :destroy
        serializer_options.include_ability read: true
        serializer_options.include_module_ability  spaces_module_ability_hash
        serializer_options.include_metadata
        serializer_options.include_module_metadata spaces_module_metadata_hash.merge(cache: false)
        serializer_options.cache ownerable: user
        mock = mock_for_keys(:metadata)
        serializer_options.stub stub_method, mock do
          json = serialize
        end
        mock.verify
      end

    end # collect_module_data_for

    # ### Cache json then get cached json.

    describe 'controller_call_json_method' do
      let(:stub_method) {:controller_call_json_method}

      it 'cache...all..ownerable' do
        set_serializer_options
        serializer_options.cache ownerable: user
        set_space_cache_serializer_options
        mock = mock_counter(1)
        @controller.stub stub_method, mock do
          json = serialize
        end
        mock.verify
        serializer_options.clear_collect_data
        serializer_options.clear_collect_cache_key_options
        set_serializer_options
        mock = mock_counter(0)  # all from cache
        @controller.stub stub_method, mock do
          json = serialize
        end
      end

      it 'cache..except metadata..ownerable' do
        set_serializer_options
        serializer_options.cache ownerable: user, metadata: false
        set_space_cache_serializer_options
        mock = mock_counter(1)
        @controller.stub stub_method, mock do
          json = serialize
        end
        mock.verify
        serializer_options.clear_collect_data
        set_serializer_options
        mock = mock_counter(1)
        @controller.stub stub_method, mock do
          json = serialize
        end
      end

      it 'cache..no ownerable' do
        set_serializer_options
        serializer_options.cache
        set_space_cache_serializer_options
        mock = mock_counter(1)
        @controller.stub stub_method, mock do
          json = serialize
        end
        mock.verify
        serializer_options.clear_collect_data
        set_serializer_options
        mock = mock_counter(1)  # all from cache
        @controller.stub stub_method, mock do
          json = serialize
        end
        mock.verify
      end

    end # controller_call_json_method

  end

end; end; end
