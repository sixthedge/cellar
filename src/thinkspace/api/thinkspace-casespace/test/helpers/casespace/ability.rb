module Test::Casespace::Ability
  extend ActiveSupport::Concern

  class_methods do
    def alias_read_actions; [:read, :index, :show, :select, :view]; end
    def ability_class;       Thinkspace::Authorization::Ability; end

    def set_test_ability_classes(paths)
      class_paths = Array.new
      [paths].flatten.compact.each do |path|
        raise "Ability files directory is does not exist #{path.inspect}."  unless File.directory?(path)
        class_paths.push(path: path)
      end
      ability_class.load_ability_classes(class_paths)
    end

  end # class methods

  included do

    def ability_class;       Thinkspace::Authorization::Ability; end
    def ability_error_class; Thinkspace::Authorization::AbilityError; end

    # def alias_read_actions; [:read, :index, :show, :select, :view]; end
    def alias_read_actions; self.class.alias_read_actions; end

    def get_ability(username); ability_class.new(get_user(username)); end

    def get_accessible_by(klass, username, options={})
      action    = options[:action]    || :read
      debug_sql = options[:debug_sql] || false
      query     = klass.accessible_by(get_ability(username), action)
      print_sql(klass, username, action, query)  if debug_sql
      query.respond_to?(:to_a) ? query.to_a : query
    end

    # Print accesssible_by sql
    def print_sql(klass, username, action, query)
      sql = query.to_sql
      puts "\n\nDebug SQL: Class=#{klass.name.inspect}  User=#{username.inspect}  Action=#{action.to_s.inspect}"
      puts "  SQL=#{sql}"
      puts "\n"
    end

    def get_ability_subject_name(subject)
      return subject.name if subject.is_a?(Class)
      id    = subject.respond_to?(:id)    ? subject.id : ''
      title = subject.respond_to?(:title) ? subject.title : ''
      "#{subject.class.name}.#{subject.id} #{title}"
    end

  end # included
end
