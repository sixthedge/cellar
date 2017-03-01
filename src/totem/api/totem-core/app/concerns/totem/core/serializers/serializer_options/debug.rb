module Totem; module Core; module Serializers; module SerializerOptions; module Debug

  # ###
  # ### Debug.
  # ###

  def debug_on
    debug_abilities_on
    debug_authorize_on
    debug_authorize_blank_on
  end

  def debug_log(message)
    debug_options[:debug_log] ||= Array.new
    debug_options[:debug_log].push(message)
  end

  def debug_abilities_on;       debug_options[:debug_abilities]       = true; end
  def debug_authorize_on;       debug_options[:debug_authorize]       = true; end
  def debug_authorize_blank_on; debug_options[:debug_authorize_blank] = true; end
  def debug_run_on;             debug_options[:debug_run]             = true; end  # print debug msgs as created

  def debug?; debug_abilities? || debug_authorize? || debug_authorize_blank?; end
  def debug_abilities?;       debug_options[:debug_abilities]; end
  def debug_authorize?;       debug_options[:debug_authorize]; end
  def debug_authorize_blank?; debug_options[:debug_authorize_blank]; end
  def debug_run?;             debug_options[:debug_run]; end

  def print_log_summary
    debug_options[:debug_log] ||= Array.new
    puts "\nSerializer Debug Log - Total Entries=#{debug_options[:debug_log].length}"
  end

  def print_log
    print_log_summary
    lc = 0
    debug_options[:debug_log].each {|l| puts "#{lc+=1}. ".rjust(8) + l}
    print_log_summary
  end

  def print_log_sorted(options={})
    print_log_summary
    lc = 0
    if options[:unique]
      debug_options[:debug_log].uniq.sort.each {|l| puts "#{lc+=1}. ".rjust(8) + "#{l} [count: #{debug_options[:debug_log].count(l)}]"}
    else
      debug_options[:debug_log].sort.each {|l| puts "#{lc+=1}. ".rjust(8) + l}
    end
    print_log_summary
  end

  def print_options
    puts "\nSerializer Options"
    puts "Default Options:"
    default_options.each_pair {|k,v| puts "  #{k.inspect}: #{v.inspect}"}
    puts "Global Options:"
    global_serializer_options.each_pair {|k,v| puts "  #{k.inspect}: #{v.inspect}"}
    puts "Root Options:"
    root_serializer_options.each_pair {|k,v| puts "  #{k.inspect}: #{v.inspect}"}
    puts "Association Options:"
    association_serializer_options.each_pair do |key, values|
      puts "  #{key.inspect}"
      values.each_pair {|k,v| puts "    #{k.inspect}: #{v.inspect}"}
    end
    puts "Custom Options:"
    custom_serializer_options.each_pair {|k,v| puts "  #{k.inspect}: #{v.inspect}"}
    puts "Debug Options:"
    debug_options.except(:debug_log).each_pair {|k,v| puts "  #{k.inspect}: #{v.inspect}"}
    puts "\n"
  end

end; end; end; end; end
