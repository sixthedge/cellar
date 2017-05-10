require File.expand_path('../markup_comments', __FILE__)
class AutoInputArtifacts < AutoInputBase

  # Auto input example:
  #   artifacts:
  #     - only:           phase_a
  #       users:          [read_1, read_2, read_3]
  #       files:          file.pdf
  #       rename:         true      #=> prepend user's first name to file name (done only when paperclip storage is 'filesystem') e.g. read_1-file.pdf
  #       comments:       2         #=> number of markup comments to auto-generate
  #       comment_values:           #=> coordinates of comments; markup_comments will try to prevent overlaps (defaults to x=0, y=0, page=1)
  #         - {x:         384, y: 144, page: 1}
  #         - {x:         384, y: 244, page: 1}
  #       # 'dir' only needed if files are not in 'thinkspace-casespace/db/test_data/files'
  #       dir: '../../../seed_files'  #=> file path relative to 'Rails.root'
  #       dir: staging                #=> file path relative to 'thinkspace-casespace/db/test_data'

  def process(options)
    @phases = selected_phases
    @files  = [options[:files]].flatten.compact
    @dir    = options[:dir] || ''
    @rename = options[:rename] || false
    process_phases
    add_markup_comments if options[:comments]
  end

  def add_markup_comments
    @phases.each do |phase|
      users   = get_phase_users(phase)
      files   = file_class.where(ownerable: users)
      values  = [{"position"=>{"x"=>384, "y"=>144, "page"=>1}}]
      options = @options.merge({only: phase.title, discussionables: files, values: values})
      ::AutoInputMarkupComments.new(@caller, @seed, @config_models, @config, options)
    end
  end

  def process_phases
    @phases.each do |phase|
      users = get_phase_users(phase)
      process_phase_users(phase, users)
    end
  end

  def process_phase_users(phase, users)
    users.each do |user|
      bucket = find_or_create_bucket(phase, user)
      add_artifact_files(phase, user, bucket)
    end
  end

  def add_artifact_files(phase, user, bucket)
    @files.each do |file|
      path          = get_attachment_path(file)
      artifact_file = create_file(bucket, user, user, path)
      if rename?
        new_file = "#{user.first_name}-#{file}"
        rename_file(artifact_file, new_file)
      end
    end
  end

  # If the 'dir' value contains '../' will be relative to the Rails.root otherwise relative to "db/test_data/#{dir}/files".
  def get_attachment_path(file); @dir.match(/^\.\.\//) ? get_rails_attachment_path(file) : get_seed_attachment_path(file); end

  def get_rails_attachment_path(file)
    path = Rails.root.join(@dir, file)
    error "Artifact path #{path.inspect} is not a file." unless File.file?(path)
    path
  end

  def get_seed_attachment_path(file)
    ns_dir = @seed.db_data_dir(:seed)
    path   = File.join(ns_dir, @dir, 'files', file)
    error "Artifact path #{path.inspect} is not a file." unless File.file?(path)
    path
  end

  def find_or_create_bucket(authable, user)
    options = {authable: authable}
    bucket  = bucket_class.find_by(options)
    return bucket if bucket.present?
    bucket = @seed.new_model(:artifact, :bucket, options.merge(user_id: user.id))
    @seed.create_error(bucket)  unless bucket.save
    bucket
  end

  def create_file(bucket, user, ownerable, path)
    options         = {bucket: bucket, user: user, ownerable: ownerable}
    file            = @seed.new_model(:artifact, :file, options)
    file.attachment = File.open(path)
    @seed.create_error(file)  unless file.save
    file
  end

  def rename_file(artifact_file, new_file)
    unless local_storage?
      @seed.message "   !!Artifact 'rename' requires Paperclip using the 'filesystem'.  Renaming will not be done.\n\n", :warn
      @rename = false
      return
    end
    path = artifact_file.attachment.path
    file = File.basename(path)
    dir  = File.dirname(path)
    error "Artifact rename file file #{path.inspect} is not a file." unless File.file?(path)
    error "Artifact rename file directory #{dir.inspect} is not a directory." unless File.directory?(dir)
    Dir.chdir dir do
      File.rename(file, new_file)
    end
    artifact_file.attachment_file_name = new_file
    @seed.create_error(artifact_file)  unless artifact_file.save
  end

  def rename?; @rename == true; end

  def local_storage?; Paperclip::Attachment.default_options[:storage] == :filesystem; end

  def bucket_class; @_bucket_class ||= @seed.model_class(:artifact, :bucket); end
  def file_class;   @_file_class   ||= @seed.model_class(:artifact, :file); end

end
