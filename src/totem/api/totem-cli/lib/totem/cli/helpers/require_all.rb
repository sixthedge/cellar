require 'rbconfig'
require 'yaml'
require 'pathname'
require 'pp'

begin
  require 'thor'
  require 'thor/group'
rescue LoadError
  puts "\n"
  puts "Please either install Thor or set your gemset to one that includes the thor gem (e.g. rvm gemset use NAME), then re-run."
  puts "\n"
  exit 1
end

# Rails core extensions for string, array and hash
begin
  require 'active_support/core_ext/object/deep_dup'
  require 'active_support/core_ext/string'
  require 'active_support/core_ext/array'
  require 'active_support/core_ext/hash'
  require 'active_support/core_ext/hash/deep_merge'
rescue LoadError
  puts "\n"
  puts "Please either install Rails (e.g. gem install rails -N) or set your gemset to one that includes the Rails gem (e.g. rvm gemset use NAME), then re-run."
  puts "\n"
  exit 1
end

# common helpers
helper_files = Dir.glob(File.expand_path("../../helpers/**/*.rb", __FILE__))
helper_files.each do |file|
   require file
end

# program specific helpers
if defined?(HELPERS_DIR) && HELPERS_DIR
  [HELPERS_DIR].flatten.compact.each do |dir|
    helper_files = Dir.glob(File.expand_path("../../#{dir}/**/*.rb", __FILE__))
    helper_files.each do |file|
      require file
    end
  end
end
