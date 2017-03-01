require 'serializer_helper'
Test::Casespace::Seed.load(config: :serializer)
module Test; module Serializer; class CacheQueryKeyPhase < ActionController::TestCase
  include Controller
  include Model
  include Assert
  include ModuleMethods

  def create_phase_association_records
    @team_category_id      = 99
    phase                  = record
    phase.team_category_id = @team_category_id
    phase.save
    comp = phase.thinkspace_casespace_phase_components.create(phase_id: phase.id)
    phase.thinkspace_casespace_phase_components.create(phase_id: phase.id)
    phase.thinkspace_casespace_phase_components.create(phase_id: phase.id)
    phase.thinkspace_resource_tags.create(user_id: user.id, taggable_id: phase.id, taggable_type: phase.class.name, title: Time.now.to_s)
    phase.thinkspace_resource_files.create(user_id: user.id, resourceable_id: phase.id, resourceable_type: phase.class.name, file_file_name: Time.now.to_s)
    phase.thinkspace_resource_links.create(user_id: user.id, resourceable_id: phase.id, resourceable_type: phase.class.name, title: Time.now.to_s)
    tag  = phase.thinkspace_resource_tags.create(user_id: user.id, taggable_id: phase.id, taggable_type: phase.class.name, title: Time.now.to_s)
    file = phase.thinkspace_resource_files.create(user_id: user.id, resourceable_id: phase.id, resourceable_type: phase.class.name, file_file_name: Time.now.to_s)
    link = phase.thinkspace_resource_links.create(user_id: user.id, resourceable_id: phase.id, resourceable_type: phase.class.name, title: Time.now.to_s)
    comp.touch
    @component_timestamp      = cache_timestamp(comp.reload)
    @tag_timestamp            = cache_timestamp(tag.reload)
    @file_timestamp           = cache_timestamp(file.reload)
    @link_timestamp           = cache_timestamp(link.reload)
    @phase_timestamp          = cache_timestamp(phase.reload)
    @phase_template_timestamp = cache_timestamp(phase.thinkspace_casespace_phase_template)
    @configuration_timestamp  = cache_timestamp(phase.thinkspace_common_configuration)
  end

  def assert_key_match(key)
    assert_match /.*phase\/#{@phase_timestamp}/, key, '==> serializer options cache key does not include phase timestamp'
    assert_match /.*phase_template\/#{@phase_template_timestamp}/, key, '==> serializer options cache key does not include phase_tempalte timestamp'
    assert_match /.*phase_components\/#{@component_timestamp}/, key, '==> serializer options cache key does not include phase components timestamp'
    assert_match /.*configuration\/#{@configuration_timestamp}/, key, '==> serializer options cache key does not include configuration timestamp'
    assert_match /.*team_category_id\/#{@team_cateogry_id}/, key, '==> serializer options cache key does not include team_category_id'
    assert_match /.*resource_tags\/#{@tag_timestamp}/, key, '==> serializer options cache key does not include tag timestamp'
    assert_match /.*resource_files\/#{@file_timestamp}/, key, '==> serializer options cache key does not include file timestamp'
    assert_match /.*resource_links\/#{@link_timestamp}/, key, '==> serializer options cache key does not include link timestamp'
  end

  describe @phases_controller do
    let(:user)   {serializer_update_user}
    describe 'phase load' do
      let(:record) {serializer_phase}
      let(:action) {:load}

      it 'serializer options digest with created association records' do
        create_phase_association_records
        serializer_options.cache
        serializer_options.cache_query_key name: :phase
        serializer_options.cache_query_key name: :phase_template,   pluck: :thinkspace_casespace_phase_template
        serializer_options.cache_query_key name: :configuration,    pluck: :thinkspace_common_configuration
        serializer_options.cache_query_key name: :phase_components, maximum: :thinkspace_casespace_phase_components
        serializer_options.cache_query_key name: :team_category_id, column: :team_category_id
        serializer_options.cache_query_key name: :resource_tags,    maximum: :thinkspace_resource_tags
        serializer_options.cache_query_key name: :resource_files,   maximum: :thinkspace_resource_files
        serializer_options.cache_query_key name: :resource_links,   maximum: :thinkspace_resource_links
        key    = cache_key(serializer_options.cache_options)
        digest = cache_digest(key)
        # print_cache_key_and_digest(key, digest, 'Serializer options generated')
        assert_key_match(key)
      end

      # # ### Start TEMPORARY tests used during convertion to serializer options.
      # # ### Check if model generated digest matches serializer options digest.
      # it 'model digest match serializer options digest' do
      #   serializer_options.cache
      #   okey    = cache_key
      #   odigest = cache_digest(okey)
      #   # print_cache_key_and_digest(okey, odigest, 'Model generated')
      #   serializer_options.cache_query_key name: :phase
      #   serializer_options.cache_query_key name: :phase_template,   pluck: :thinkspace_casespace_phase_template
      #   serializer_options.cache_query_key name: :configuration,    pluck: :thinkspace_common_configuration
      #   serializer_options.cache_query_key name: :phase_components, maximum: :thinkspace_casespace_phase_components
      #   serializer_options.cache_query_key name: :team_category_id, column: :team_category_id
      #   serializer_options.cache_query_key name: :resource_tags,    maximum: :thinkspace_resource_tags
      #   serializer_options.cache_query_key name: :resource_files,   maximum: :thinkspace_resource_files
      #   serializer_options.cache_query_key name: :resource_links,   maximum: :thinkspace_resource_links
      #   key    = cache_key(serializer_options.cache_options)
      #   digest = cache_digest(key)
      #   # print_cache_key_and_digest(key, digest, 'Serializer options generated')
      #   assert_equal odigest, digest, 'serializer options generated digest matches model generated digest'
      # end
      # it 'model digest match serializer options digest with created association records' do
      #   create_phase_association_records
      #   serializer_options.cache
      #   okey    = cache_key
      #   odigest = cache_digest(okey)
      #   # print_cache_key_and_digest(okey, odigest, 'Model generated')
      #   serializer_options.cache_query_key name: :phase
      #   serializer_options.cache_query_key name: :phase_template,   pluck: :thinkspace_casespace_phase_template
      #   serializer_options.cache_query_key name: :configuration,    pluck: :thinkspace_common_configuration
      #   serializer_options.cache_query_key name: :phase_components, maximum: :thinkspace_casespace_phase_components
      #   serializer_options.cache_query_key name: :team_category_id, column: :team_category_id
      #   serializer_options.cache_query_key name: :resource_tags,    maximum: :thinkspace_resource_tags
      #   serializer_options.cache_query_key name: :resource_files,   maximum: :thinkspace_resource_files
      #   serializer_options.cache_query_key name: :resource_links,   maximum: :thinkspace_resource_links
      #   key    = cache_key(serializer_options.cache_options)
      #   digest = cache_digest(key)
      #   # print_cache_key_and_digest(key, digest, 'Serializer options generated')
      #   assert_equal odigest, digest, 'serializer options generated digest matches model generated digest'
      #   assert_key_match(key)
      # end
      # # ### End TEMPORARY tests during convertion to serializer options.

    end
  end

end; end; end
