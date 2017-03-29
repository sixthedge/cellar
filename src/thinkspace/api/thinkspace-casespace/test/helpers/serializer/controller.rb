module Test::Serializer::Controller
  extend ActiveSupport::Concern

  included do

    @spaces_controller      = Thinkspace::Common::Api::SpacesController
    @assignments_controller = Thinkspace::Casespace::Api::AssignmentsController
    @phases_controller      = Thinkspace::Casespace::Api::PhasesController
    # @contents_controller    = Thinkspace::Html::Api::ContentsController

    def serializer_options; @controller.send :serializer_options; end
    def current_user(user); @controller.instance_variable_set(:@current_user, user); end
    def action_name(name);  @controller.action_name = name.to_s; end

    def ability_model_path;  @controller.send :controller_ability_model_path; end
    def metadata_model_path; @controller.send :controller_metadata_model_path; end

    def space_metadata_value;      {count: 1, open: 1, can_clone: true}; end
    def assignment_metadata_value; {count: 2, completed: 0}; end

    def serialize(options={})
      json = controller_json(options)
      controller_after_json(json, options)
    end

    def cache_error_class; Totem::Core::Controllers::ApiRender::Cache::CacheError; end

    def set_space_cache_serializer_options; serializer_options.cache_query_key name: :spaces; end

    def controller_json(options={})
      verify_test_environment_controller_cache
      options[:cache_keys] = name  if serializer_options.cache? && options[:cache_keys].blank?  # make cache keys unique with test name
      current_user(user)
      action_name(action)
      @controller.controller_json(record, options)
    end

    def controller_after_json(json, options={})
      @controller.controller_after_json(json, options)
      json
    end

    def print_serializer_options; serializer_options.print_debug_options; end

    def controller_cache?; ::Rails.configuration.action_controller.perform_caching.present?; end
    def memory_store?;     ::Rails.configuration.cache_store == :memory_store; end

    def verify_test_environment_controller_cache
      return unless serializer_options.cache?
      return if controller_cache? && memory_store?
      message = "\n***\n"
      message += "  Testing cache serializer options but the test environment does not have cache memory store enabled! In config/environments/test.rb add:\n"
      message += "     config.action_controller.perform_caching = true\n"
      message += "     config.cache_store                       = :memory_store\n"
      message += "***\n"
      assert_equal true, false, message
    end

    def cache_timestamp(record, col=:updated_at); record.send(col).utc.to_s(:nsec); end

    def cache_key(options={}); action_name(action); @controller.send(:controller_cache_key, record, options); end

    def cache_digest(key); @controller.send(:controller_cache_key_digest, key); end

    def build_cache_query_key(query_key)
      parts = Array.new
      @controller.send(:controller_cache_convert_timestamp_to_keys, parts, query_key)
      @controller.send(:controller_cache_add_serializer_options_cache_values, parts, {})
      parts
    end

    def print_cache_key_and_digest(key, digest, title=nil)
      puts "\n\n"
      puts "#{title.to_s.ljust(80,'-')}"  if title.present?
      puts "KEY: (#{key.length})", key.inspect
      puts "DIGEST: (#{digest.length})", digest.inspect
    end

    def print_cache_key(title=nil)
      key    = cache_key
      digest = cache_digest(key)
      print_cache_key_and_digest(key, digest, title)
      digest
    end

  end # included
end
