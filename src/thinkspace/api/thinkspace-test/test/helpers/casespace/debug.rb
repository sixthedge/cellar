module Test::Casespace::Debug
  extend ActiveSupport::Concern
  included do

    def debug_on; false; end

    # NON-controller log.  
    def print_log
      return if name.blank?
      log = debug_log
      puts "\n"
      if log.present?
        puts "# Log for test [#{name}]:\n\n"
        puts log.collect {|l| '  ' + l}
      else
        puts "# Log [#{name}]:\n"
        puts "No test log found.\n"
      end
      puts "\n"
    end

    def debug_log
      match   = name.to_s
      log     = Array.new
      collect = false
      debug_open_test_log_file.each_line do |line|
        if line.chomp.end_with?(match)
          collect = true
          log     = Array.new  if log.present?  # only collect the last one
          next
        end
        if line.start_with?('-----------')
          collect = false  if log.present?
          next
        end
        log.push(line) if collect && !debug_ignore_log_line?(line)
      end
      log
    end

    def print_controller_log
      log = debug_controller_log
      puts "\n"
      if log.present?
        puts "# Controller log [#{method_name}]:\n"
        puts log.collect {|l| '  ' + l}
      else
        puts "No controller log found.\n"
      end
      puts "\n"
    end

    def debug_controller_log
      # Assumes tests are nested:
      #   describe controller-class
      #     describe 'action-name' (or describe 'action-name followed-by-space-and-addition-text')
      #       it 'test-name'
      #       describe 'sub-action describe text'
      # Each 'describe' text is appended to the test class name (e.g. self.class.name::describe-1-text::describe-2-text),
      # so ok to nest describes after the action describe.
      return [] if _controller_class.blank?
      class_name = _controller_class.name
      action     = self.class.name.sub(class_name+'::', '')
      action     = action.split('::').first.split(' ').first.sub(':', '')
      match      = class_name + "##{action}"
      log        = Array.new
      collect    = false
      debug_open_test_log_file.each_line do |line|
        if line.start_with?('Processing by') && line.match(match)
          collect = true
          log     = Array.new  if log.present?  # only collect the last one
        end
        if line.start_with?('-----------')
          collect = false
          next
        end
        if collect
          next if debug_ignore_log_line?(line)
          if line.match('Parameters:')
            log.push "\n"
            log.push line
            log.push "\n"
          else
            log.push line
          end
        end
      end
      log
    end

    def print_controller_params
      log = debug_controller_log
      if log.present?
        params = log.select {|l| l.match('Parameters:')}
        puts "# Controller params [#{self.class.name}]:\n"
        puts params
      else
        puts "No controller params found.\n"
      end
      puts "\n"
    end

    def debug_ignore_log_line?(line)
      return true if line.start_with?('[debug]')   # skip any totem debug logs
      return true if line.start_with?('[warning]') # skip any totem debug logs
      return true if line.start_with?('[WARNING]') # skip any totem debug logs
      false
    end

    def debug_open_test_log_file
      log_file = Rails.root.join('log/test.log')
      unless File.exists?(log_file)
        puts "[error] Log file #{log_file.inspect} does not exist."
        return
      end
      File.open(log_file)
    end

    def debug_sql(klass, username, options={})
      action = options[:action]    || :read
      query  = klass.accessible_by(get_ability(username), action)
      sql    = query.to_sql
      puts "\n\n"
      puts '-' * 100
      puts "Debug SQL: Class=#{klass.name.inspect}  User=#{username.inspect}  Action=#{action.inspect}"
      puts "\n"
      select, from = sql.split('FROM', 2)
      parts = select.split(',')
      puts "  #{parts.shift.strip}"
      if options[:select]
        parts.each do |part|
          puts "     #{part.strip}"
        end
      end
      puts "\n"
      parts = from.split(/([A-Z]+\s*[A-Z]*\s*[A-Z]*)/)
      puts "  FROM #{parts.shift.strip}"
      i = 0
      while (i < parts.length)
        part = parts[i].strip
        i += 1
        next if part.blank?
        if part.match('JOIN') || part.match('WHERE')
          puts "\n"
          puts "    #{part} #{parts[i].strip}"
          i += 1
        elsif part.match(/[A-Z]+/)
          puts "      #{part} #{parts[i].strip}"
          i += 1
        else
          puts "      #{part}"
        end
      end
      puts '-' * 100
      puts "\n\n"
    end

  end # included
end
