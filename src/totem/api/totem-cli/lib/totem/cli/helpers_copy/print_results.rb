module Totem; module Cli; module HelpersCopy; module PrintResults

  def print_quiet?; options[:quiet]; end

  def print_filename(filename, color=:yellow)
    @total_files_copied += 1
    return unless print_files_copied?
    return if print_quiet?
    full = Pathname.new(filename.to_s)
    root = Pathname.new(run_dir_pwd)
    file = full.relative_path_from(root)
    say_message "File: #{file.to_s.inspect}", color
  end

  def print_file_content_summary
    say ''
    return if print_quiet?
    if @gsub_file_content_change_counts.blank?
      say "No summary file content changes made.", :yellow
      return
    end
    say "File content changes:", :cyan
    files = @gsub_file_content_change_counts.keys.sort
    files.each do |file|
      changes = @gsub_file_content_change_counts[file]
      print_filename(file)
      changes.each do |from, to_changes|
        to_changes.each do |to, count|
          key   = get_summary_change_key(from: from, to: to)
          cnt = "(#{count}) ".ljust(6)
          say "  #{cnt} #{key}", :cyan
        end
      end
    end
  end

  def print_summary
    return if print_quiet?
    say ''
    if @gsub_content_change_counts.blank?
      say "No summary changes made.", :yellow
      return
    end
    say "Summary of changes (files copied: #{@total_files_copied}):", :green
    # total count and file count of each conversion from/to
    total_counts = Hash.new(0)
    file_counts  = Hash.new(0)
    @gsub_content_change_counts.each do |from, to_changes|
      to_changes.each do |to, count|
        key               = get_summary_change_key(from: from, to: to)
        total_counts[key] = count
        from_values       = @gsub_file_content_change_counts.values.select{|hash| hash.has_key?(from)}
        file_counts[key]  = from_values.length
      end
    end
    # get max from/to string lengths
    from_len    = 0
    to_len      = 0
    conversions = get_content_conversions
    conversions.each do |hash|
      kl       = hash.keys.collect {|k| k.to_s.length}.max
      vl       = hash.values.collect {|v| v.to_s.length}.max
      from_len = kl if kl > from_len
      to_len   = vl if vl > to_len
    end
    c_count = 0
    conversions.each do |hash|
      hash.each do |from, to|
        num       = (c_count += 1).to_s.rjust(3)
        count_key = get_summary_change_key(from: from, to: to)
        c_from    = from.to_s.ljust(from_len)
        c_to      = to.to_s.ljust(to_len)
        change    = "#{c_from} => #{c_to}"
        file_cnt  = file_counts[count_key].to_s.rjust(5)
        chg_cnt   = total_counts[count_key].to_s.rjust(5)
        say "#{num}. #{change}  File count: #{file_cnt}  Change count: #{chg_cnt}", :green
      end
    end
  end

  def get_summary_change_key(change)
    from = change[:from].to_s.sub(/^\//,'').sub(/\/$/,'')
    to   = change[:to]
    "#{from} => #{to}"
  end

  def print_no_gsub_directories
    if @no_gsub_directories.blank?
      say ''
      say "All directory files had gsub performed.", :yellow
      return
    end
    say ''
    say "Directories without gsub performed:", :green
    @no_gsub_directories.uniq.sort.each do |dir|
      say "   #{dir}", :green
    end
  end

end; end; end; end
