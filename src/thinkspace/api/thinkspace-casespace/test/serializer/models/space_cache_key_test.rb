require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class ModelsSpaceCacheKey < ActionController::TestCase
  include Controller
  include Model
  include Assert
  include ModuleMethods

  def cache_key; action_name(action); @controller.send(:controller_cache_key, record, {}); end

  def cache_digest(key); @controller.send(:controller_cache_key_digest, key); end

  def print_cache_key
    puts "\n\n"
    key    = cache_key
    digest = cache_digest(key).inspect
    puts "KEY (#{key.length})", key.inspect
    puts "DIGEST (#{digest.length})", digest
  end

  describe @spaces_controller do
    let(:user)   {serializer_update_user}
    describe 'models..space.all..index cache key' do
      let(:record) {all_serializer_spaces}
      let(:action) {:index}
      it 'cache..module_ability..module metadata..no ownerable' do
        serializer_options.ability_actions :update
        serializer_options.include_ability ability: true
        serializer_options.include_metadata
        serializer_options.include_module_ability  spaces_module_ability_hash
        serializer_options.include_module_metadata spaces_module_metadata_hash
        serializer_options.cache metadata: false
        set_space_cache_serializer_options
        # print_cache_key
      end
    end

    describe 'cache key for phase without associations..should not error' do
      let(:record) {phase_class.create(title: 'test phase without associations')}
      let(:action) {:index}
      it 'no phase associations' do
        serializer_options.cache
        serializer_options.cache_query_key name: :phase
        serializer_options.cache_query_key name: :phase_template,   pluck: :thinkspace_casespace_phase_template
        serializer_options.cache_query_key name: :configuration,    pluck: :thinkspace_common_configuration
        serializer_options.cache_query_key name: :phase_components, maximum: :thinkspace_casespace_phase_components
        cache_key
        # print_cache_key
      end
    end

  end
end; end; end
