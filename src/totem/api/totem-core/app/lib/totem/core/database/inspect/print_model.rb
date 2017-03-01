module Totem; module Core; module Database; module Inspect; class PrintModel

  # Print Table records.
  # See documentation at end of this file or run a rake task with [help].

  require 'pp'

  attr_reader :run_model_class
  attr_reader :run_scope

  attr_reader :arg_ids
  attr_reader :arg_order
  attr_reader :arg_scopes
  attr_reader :arg_columns
  attr_reader :arg_to_yaml
  attr_reader :arg_show_help
  attr_reader :arg_quiet
  attr_reader :arg_str

  def initialize
    @arg_ids       = Array.new
    @arg_order     = Array.new
    @arg_scopes    = Array.new
    @arg_columns   = Array.new
    @arg_to_yaml   = false
    @arg_show_help = false
    @arg_quiet     = false
  end

  def process(args=nil)
    extract_args(args)
    case
    when show_help?
      print_help
    when arg_to_yaml
      print_sep
      record_attributes = run_scope.map {|record| record.attributes}
      puts record_attributes.to_yaml
    else 
      print_sep
      run_scope.each do |record|
        print_record(record)
      end
    end
  end

  def extract_args(args)
    args     = [args].flatten.compact.collect {|v| v.strip}
    @arg_str = args.join(',')
    if args.include?('help') || args.include?('h')
      @arg_show_help = true
      return
    end
    set_model_class(args)
    set_run_scope(args)
    print_run_values
  end

  def set_model_class(args)
    model_name = args.shift
    stop_run "Model class is blank.  The first arg must the model class." if model_name.blank?
    @run_model_class = model_name.classify.safe_constantize
    stop_run "Model class #{model_name.inspect} cannot be constantized." if run_model_class.blank?
  end

  def set_run_scope(args)
    scope = run_model_class.all
    args.each do |arg|
      key, value = get_arg_values(arg)
      case key
      when 'order', 'o'
        order       = get_arg_values(arg).last
        order, sort = get_arg_values(order)
        order       = "#{order} #{sort}"  if sort.present?
        arg_order.push(order)
      when 'offset'
        num   = get_arg_number(arg)
        scope = scope.offset(num)
        arg_scopes.push("offset(#{num})")
      when 'limit', 'l'
        num   = get_arg_number(arg)
        scope = scope.limit(num)
        arg_scopes.push("limit(#{num})")
      when 'column', 'c'
        arg_columns.push(value)
      when 'yaml', 'yml'
        @arg_to_yaml = true
      when 'quiet', 'q'
        @arg_quiet = true
      else
        if is_digits?(arg)
          arg_ids.push(arg.to_i)
        end
      end
    end
    scope      = scope.where(id: arg_ids)  if arg_ids.present?
    scope      = scope.order(arg_order)    if arg_order.present?
    @run_scope = scope
  end

  def get_arg_values(arg); arg.split(':',2); end

  def get_arg_number(arg)
    key, value = get_arg_values(arg)
    stop_run "Arg #{arg.inspect} must have a number value not #{value.inspect}." unless is_digits?(value)
    value.to_i
  end

  def is_digits?(arg)
    return false if arg.blank?
    arg.match(/^\d+$/)
  end

  def show_help?; arg_show_help.present?; end
  def quiet?;     arg_quiet.present?; end

  # ###
  # ### Print Helpers.
  # ###

  def print_run_values
    return if quiet?
    puts "\nRun values:"
    print_run_value 'Class',        run_model_class.name
    print_run_value 'Arg string',   (arg_str || '').inspect
    print_run_value 'Ids',          arg_ids
    print_run_value 'Order',        arg_order
    print_run_value 'Columns',      arg_columns
    print_run_value 'Scopes',       arg_scopes
    print_run_value 'Quiet',        arg_quiet
  end

  def print_run_value(text, values, sub_text='')
    return if values.blank?
    len = 20
    puts "   #{text}#{sub_text}".ljust(len) + ": #{values}"
  end

  def print_sep
    sep = "#{run_model_class.name.pluralize.gsub('::',' ')}" + '-' * 80
    puts "\n#--" + sep + "\n\n"
  end

  def print_record(record)
    if arg_columns.blank?
      print_record_header(record)
      pp record
    else
      print_record_header(record)
      print_columns(record)
    end
  end

  def print_columns(record)
    @_max_col_len ||= arg_columns.map{|c| c.to_s.length}.max + 2
    arg_columns.each do |col|
      value = record[col]
      puts "  #{col.ljust(@_max_col_len,'.')}#{value.inspect}"
    end
  end

  def print_record_header(record)
    title = record.respond_to?(:title) ? "title: #{record.title}" : ''
    hdr   = "--id:#{record.id} #{title}"
    puts hdr.ljust(60,'-')
  end

  def stop_run(message='')
    puts "\n"
    puts "Run stopped. " + message
    exit
  end

        def print_help
          help = <<HELP
Run help:
  rake task options:
    [help|h] print help

    * model class must be the first argument
    * other options can be in any order in the argument string

    [model-class]     model class name e.g. Thinkspace::Common::User or thinkspace/common/user

    scope-related:     
      [#,#,...]         record ids for the main run class e.g item, assessment_item
      [limit:#|l:#]     limit records to #
      [offset:#]        offset records starting at #
      [order:col|o:col] order by column; each column value can add a sort order [asc|desc] e.g. order:id:desc,order:title:asc

    column-related:
      [c:col1,c:col2,...]   column names to print

    print_related:
      [yaml|yml]        print in yaml format
      [quiet|q]         do not print run values

  Examples:
    rake totem:db:inspect:print[Thinkspace::Common::User]                 #=> print all
    rake totem:db:inspect:print[Thinkspace::Common::User,l:3,o:title]     #=> print 3 records order by title
    rake totem:db:inspect:print[Thinkspace::Common::User,1,2,3,o:title]   #=> print ids [1,2,3] order by title

  Redirect ouput:
    rake .... >  myfile.txt  # create myfile.txt
    rake .... >> myfile.txt  # append myfile.txt

HELP
          puts help
        end



end; end; end; end; end
