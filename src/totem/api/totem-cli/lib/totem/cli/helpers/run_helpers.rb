module Totem; module Cli; module Helpers;  module RunHelpers

  # Thor run time options
  def force?;   run_options[:force]; end    # overwrite files that alreay exist
  def pretend?; run_options[:pretend]; end  # run but do not make any changes
  def quiet?;   run_options[:quiet]; end    # suppress status output
  def skip?;    run_options[:skip]; end     # skip files that already exist

  # Run Options
  def debug?;        run_options[:debug]; end
  def new?;          run_options[:new]; end
  def onew?;         options[:new] == true; end  # command line options (e.g. not run options override)
  def deploy?;       run_options[:deploy]; end
  def package?;      run_options[:package]; end
  def verify?;       run_options[:verify] && !quiet?; end
  def verbose_copy?; run_options[:verbose_copy] && !quiet?; end
  def verbose_debug?; debug? && verbose_copy?; end
  def skip_exist_check?; run_options[:skip_exist_check]; end

  def capture_output?; not (verbose_copy? || debug?); end

  def skip_package?(pkg); pkg && pkg.start_with?('--'); end

  def get_class_group_run_options(group)
    group_options   = Array.new
    thor_group_name = group.to_s.capitalize  # Thor typically uses 'group' to print options so is human friendly
    self.class.class_options.each do |key, opt|
      group_options.push(key) if opt.group == thor_group_name
    end
    group_options
  end

  def get_thor_options_from_run_options
    {force: force?, quiet: quiet?, pretend: pretend?, skip: skip?}
  end

  def get_printable_run_options
    special_keys = []
    text         = ''
    keys         = run_options.keys.sort.select {|k| !k.to_s.start_with?('_') || !special_keys.include?(k)}
    hash_keys    = keys.select {|k| run_options[k].is_a?(Hash)}
    (keys-hash_keys).each do |key|
      text += format_printable_option(key, run_options[key])
    end
    hash_keys -=  [:current_config, :current_package, :ember_cli_build, :environment] # do not print the large configs
    hash_keys.each do |key|
      text += format_printable_option(key, run_options[key], key_color: :cyan)
    end
    special_keys.each do |key|
      opts = run_options[key]
      next if opts.blank?
      keys = opts.keys.sort
      text += format_printable_option(key, '')
      keys.each do |key|
        text += format_printable_option(key, opts[key])
      end
    end
    text
  end

  def get_printable_hash(hash, options={})
    return '' unless hash.is_a?(Hash)
    text = ''
    hash.keys.sort.each do |key|
      text += format_printable_option(key, hash[key], options)
    end
    text
  end

  def format_printable_option(key, value, options={})
    width      = options[:width]  || 30
    indent     = options[:indent] || '  '
    fmt_array  = options[:format_arrays]
    key_color  = [options[:key_color]   || options[:color] || :yellow].flatten
    val_color  = value == false ? [:red] : value == true ? [:green] : [options[:value_color] || options[:color] || :yellow].flatten
    akey_color = [options[:array_key_color]  || key_color].flatten
    text       = ''
    case
    when value.is_a?(Hash)
      key_text = set_color key.to_s.ljust(width, '.'), *key_color
      text    += indent + "#{key_text}\n"
      text    += set_color indent_pp_outout(value, indent+indent), *val_color
    when value.is_a?(Array) && value.present? && fmt_array
      key_text = set_color key.to_s.ljust(width, '.'), *akey_color
      text += indent + "#{key_text}\n"
      text += set_color indent_pp_outout(value, indent+indent), *val_color
    else
      val_color  = [:cyan, :bold]  if key.to_s.start_with?('app_') || key.to_s.end_with?('_dir') || key == :run_options_file
      val_color  = [:green, :bold] if key == :app_name
      key_color  = [:green] if value == true
      key_text   = set_color key.to_s.ljust(width, '.'), *key_color
      val_text   = set_color value.to_s, *val_color
      text      += indent + "#{key_text} #{val_text}\n"
    end
    text
  end

  def indent_pp_outout(value, indent='')
    text    = ''
    pp_text = PP.pp(value,'')
    pp_text.split("\n").each {|l| text += indent+l+"\n"}
    text
  end

end; end; end; end
