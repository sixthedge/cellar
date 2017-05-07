# minitest report plugin conventions:
#   1. A 'minitest' directory immediately under a load path directory (e.g. 'test/helpers' is added to the load path
#      by the totem test runner).
#   2. Name of the plugin file must be in the form: my_name_plugin.rb.
#   3. In the Minitest module must define a class method to initialize the reporter e.g. self.plugin_my_name_init(options).
#      a. In this method must add the report class instance to the minitest reporter array e.g. self.reporter << MyName.new
#      b. FYI: the report 'class name' does not have to match the plugin name e.g. class MyDiffName < AbstractReporter.
#
module Minitest

  class ControllerFailureCounts < AbstractReporter
    attr_reader :failure_counts

    def initialize
      @failure_counts = Hash.new
      @running_count  = 0
    end

    def set_is_active(result)
      return unless @is_active.nil?
      if result.respond_to?(:report_failures) && result.report_failures.present?
        @is_active = true
      elsif result.respond_to?(:report_failures_by_count) && result.report_failures_by_count.present?
        @is_active        = true
        @report_by_counts = true
      else
        @is_active = false
      end
    end

    def is_active?; @is_active.present?; end
    def by_name?;   @report_by_counts.blank?; end

    # The 'result' parameter is the test class itself.
    def record(result)
      return if result.passed?
      set_is_active(result)
      return unless is_active?
      controller = result.instance_variable_get(:@controller)
      return if controller.blank?
      key    = controller.class.name
      counts = (failure_counts[key] ||= Hash.new(0))
      result.result_code == 'E' ? counts[:errors] += 1 : counts[:failures] += 1
      counts[:total] += 1
      add_running_count(counts)
      add_actions(result, counts)
    end

    def add_running_count(counts)
      counts[:running_counts] = Array.new  unless counts[:running_counts].is_a?(Array)
      counts[:running_counts].push(@running_count += 1)
    end

    def add_actions(result, counts)
      counts[:actions] = Array.new  unless counts[:actions].is_a?(Array)
      route = result.instance_variable_get(:@route)
      counts[:actions].push(route.action)  if route.present?
    end

    def report
      return if failure_counts.blank?
      keys = by_name? ? failure_counts.keys.sort : failure_counts.sort_by {|k,v| [v[:total],k]}.map {|a| a.first}
      puts "\n"
      puts 'Controller Failure Counts:'.ljust(110, '-')
      len = 4
      max = keys.map {|k| k.length}.max || 1
      keys.each_with_index do |key, index|
        counts   = failure_counts[key]
        e_count  = counts[:errors]   > 0 ? counts[:errors]   : ''
        f_count  = counts[:failures] > 0 ? counts[:failures] : ''
        r_counts = "[#{counts[:running_counts].join(',')}]".ljust(12, '.')
        actions  = counts[:actions].present? ? "(#{counts[:actions].join(',')})" : ''
        name     = key.ljust(max + 2,'.')
        counter  = (index + 1).to_s.rjust(4)
        failures = '.failures' + f_count.to_s.rjust(len, '.')
        errors   = 'errors'    + e_count.to_s.rjust(len, '.')
        total    = 'total'     + counts[:total].to_s.rjust(len, '.')
        puts "  #{counter}. #{name}#{failures}  #{errors}  #{total}    #{r_counts}..#{actions}"
      end
      puts "\n"
    end

  end

  def self.plugin_controller_failure_counts_init(options)
    self.reporter << ControllerFailureCounts.new
  end

end
