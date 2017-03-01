HELPERS_DIR = 'helpers_copy'
require File.expand_path('../helpers/require_all', __FILE__)

::Thor.instance_eval {remove_const('TEMPLATE_EXTNAME')} # remove the constant first to prevent a ruby warning
::Thor.const_set('TEMPLATE_EXTNAME', '_no_match_')      # change template ext so don't process .tt as templates, just copy them

module Totem; module Cli; class TotemCopy < Thor::Group
  include Thor::Actions

  add_runtime_options!

  argument :source,      type: :string, default: nil, required: false, desc: 'source directory'
  argument :destination, type: :string, default: nil, required: false, desc: 'destination directory'

  class_option :source,      type: :string, default: nil, aliases: '-s',  desc: 'source directory'
  class_option :destination, type: :string, default: nil, aliases: '-d',  desc: 'destination directory'

  class_option :from, type: :string, default: nil, aliases: '',  desc: 'from string'
  class_option :to,   type: :string, default: nil, aliases: '',  desc: 'to string'

  class_option :acronyms, type: :array, default: nil, aliases: '-A',  desc: 'one or more acronyms to apply to string#camelize e.g. TBL'

  class_option :api,                        type: :boolean, default: false, aliases: ['-a'],  desc: 'coping api code; changes gemspec and base lib file'
  class_option :print_files_copied,         type: :boolean, default: false, aliases: ['-l'],  desc: 'print list of files copied'
  class_option :print_no_gsub_dirs,         type: :boolean, default: false, aliases: ['-g'],  desc: 'print directories with no gsub performed'
  class_option :print_file_content_summary, type: :boolean, default: false, aliases: ['-c'],  desc: 'print summary of converstions per file'
  class_option :print_summary,              type: :boolean, default: true,  aliases: ['-S'],  desc: 'print summary of changes'

  include Helpers::Common
  include Helpers::RunOptions
  include Helpers::RunHelpers
  include Helpers::Package
  include Helpers::Doc

  include HelpersCopy::CopyContent
  include HelpersCopy::Conversions
  include HelpersCopy::PrintResults

  attr_reader :source_dir
  attr_reader :destination_dir

  def overview_or_examples?; doc_options; end

  def prepare_options
    initialize_run_options_and_merge_run_options_file(key: false)
    add_acronyms
    set_copy_conversion_options
  end

  def validate_options
    run_options[:destination] = nil if run_options[:destination] == 'destination' # handle when don't use '--' e.g. -debug
    source      = (run_options[:source]      ||= @source)
    destination = (run_options[:destination] ||= @destination)
    stop_run "Source argument is blank."       unless source.present?
    stop_run "Destination argument is blank."  unless destination.present?
    @source_dir      = run_options[:source_dir]      = get_absolute_path(source)
    @destination_dir = run_options[:destination_dir] = get_absolute_path(destination)
    stop_run "Source directory #{source_dir.inspect} is not a directory."  unless File.directory?(source_dir)
    stop_run "Destination directory #{destination_dir.inspect} already exits.  Delete and re-run or correct."  if File.exists?(destination_dir)
    stop_run "from=>to conversions are blank." if get_content_conversions.blank? && get_path_conversions.blank?
  end

  def pre_process
    self.class.source_root run_dir_pwd
    @total_files_copied = 0
  end

  def debug_options?
    verify_options_and_gemset  if verify?
    debug_run_options
  end

  def process
    inside run_dir_pwd do
      directory source_dir, destination_dir, verbose: verbose_copy?, :mode => preserve_file_mode? do |content|
        copy_content(content)
      end
    end
  end

  def post_process
    print_file_content_summary   if print_file_content_summary?
    print_no_gsub_directories    if print_no_gsub?
    print_summary                if print_summary?
  end

  private

  # ###
  # ### Helpers.
  # ###

  def preserve_file_mode?;         :preserve; end
  def print_files_copied?;         run_options[:print_files_copied]; end
  def print_file_content_summary?; run_options[:print_file_content_summary]; end
  def print_summary?;              run_options[:print_summary] && !pretend?; end
  def print_no_gsub?;              run_options[:print_no_gsub_dirs] && !pretend?; end

  def self.banner
    usage = <<USAGE

#{basename} [OPTIONS]
#{doc_banner_run_options}
USAGE
    usage
  end

end; end; end
