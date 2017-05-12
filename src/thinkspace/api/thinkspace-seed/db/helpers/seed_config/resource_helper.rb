#########################################################################################
# ###
# ### Resources.
# ###

def casespace_seed_config_add_resources(config)
  tags = config[:resource_tags]
  return if tags.blank?
  seed_config_message('++Adding seed config resource tags.', config)
  CreateCasespaceResourceTags.new(self, @seed, tags)
end

class CreateCasespaceResourceTags

  def initialize(caller, seed, tags)
    @caller = caller
    @seed   = seed
    @tags   = tags
    create_resources
  end

  def create_resources
    tags = [@tags].flatten.compact
    tags.each do |hash|
      case
      when hash[:assignment].present?   then add_assignment_resouces(hash)
      when hash[:phase].present?        then add_phase_resources(hash)
      else @seed.error "Resource tag [hash: #{hash.inspect}] requires an assignment or phase key."
      end
    end
  end

  def add_assignment_resouces(hash)
    title      = hash[:assignment]
    assignment = find_assignment_by_title(title)
    @seed.error "Resource tag assignment [title: #{title.inspect}] not found."  if assignment.blank?
    add_tags(assignment, hash)
  end

  def add_phase_resources(hash)
    title = hash[:phase]
    phase = find_phase_by_title(title)
    @seed.error "Resource tag phase [title: #{title.inspect}] not found."  if phase.blank?
    add_tags(phase, hash)
  end

  def add_tags(taggable, hash)
    name  = hash[:user]
    user  = get_user(name)
    tags  = [hash[:tags]].flatten.compact
    tags.each do |tag_hash|
      title = tag_hash[:title] || 'missing_resource_title'
      tag   = create_tag(title: title, taggable: taggable, user: user)
      files = [tag_hash[:files]].flatten.compact
      links = [tag_hash[:links]].flatten.compact
      add_files(taggable, tag, user, files) if files.present?
      add_links(taggable, tag, user, links) if links.present?
    end
  end

  def add_files(taggable, tag, user, files)
    files.each do |hash|
      dir           = hash[:dir]    || ''
      file          = hash[:source] || hash[:name]
      path          = get_path(dir, file)
      options       = hash.merge(path: path, resourceable: taggable, tag: tag, user: user)
      resource_file = create_file(path, options)
      name          = options[:name]
      rename_file(resource_file, name) if name.present? && name != file
    end
  end

  def add_links(taggable, tag, user, links)
    links.each do |hash|
      options = hash.merge(resourceable: taggable, tag: tag, user: user)
      create_link(options)
    end
  end

  def create_tag(options)
    tag = @seed.new_model(:resource, :tag, options)
    @seed.create_error(tag)  unless tag.save
    tag
  end

  def create_file(path, options)
    @seed.error "File path is blank."  if path.blank?
    @seed.error "File #{path.inspect} does not exist."  unless File.file?(path)
    file      = @seed.new_model(:resource, :file, options)
    file.file = File.open(path)
    @seed.create_error(file)  unless file.save
    create_file_tag(options.merge(file: file))  if options[:tag].present?
    file
  end

  def create_link(options)
    link = @seed.new_model(:resource, :link, options)
    link.title ||= 'missing link title'
    link.url   ||= 'missing link url'
    @seed.create_error(link)  unless link.save
    create_link_tag(options.merge(link: link))  if options[:tag].present?
    link
  end

  def create_file_tag(options)
    file_tag = @seed.new_model(:resource, :file_tag, options)
    @seed.create_error(file_tag)  unless file_tag.save
    file_tag
  end

  def create_link_tag(options)
    link_tag = @seed.new_model(:resource, :link_tag, options)
    @seed.create_error(link_tag)  unless link_tag.save
    link_tag
  end

  # ###
  # ### Helpers.
  # ###

  def rename_file(resource_file, new_file)
    unless local_storage?
      @seed.message "   !!Resource 'rename' requires Paperclip using the 'filesystem'.  Not renaming to #{new_file.inspect}.", :warn
      return
    end
    path = resource_file.file.path
    file = File.basename(path)
    dir  = File.dirname(path)
    @seed.error "Resource rename file file #{path.inspect} is not a file." unless File.file?(path)
    @seed.error "Resource rename file directory #{dir.inspect} is not a directory." unless File.directory?(dir)
    Dir.chdir dir do
      File.rename(file, new_file)
    end
    resource_file.file_file_name = new_file
    @seed.create_error(resource_file)  unless resource_file.save
  end

  def local_storage?; Paperclip::Attachment.default_options[:storage] == :filesystem; end

  def get_user(name);                  @caller.send :get_common_user, first_name: name; end
  def find_assignment_by_title(title); @caller.send :find_casespace_assignment, title: title; end
  def find_phase_by_title(title);      @caller.send :find_casespace_phase, title: title; end

  # If the 'dir' value contains '../' will be relative to the Rails.root otherwise relative to "db/test_data/#{dir}/files".
  def get_path(dir, file); dir.match(/^\.\.\//) ? get_rails_path(dir, file) : get_seed_path(dir, file); end

  def get_rails_path(dir, file)
    path = Rails.root.join(dir, file)
    @seed.error "Resource path #{path.inspect} is not a file." unless File.file?(path)
    path
  end

  def get_seed_path(dir, file)
    ns_dir = @seed.db_data_dir(:seed)
    path   = File.join(ns_dir, dir, 'files', file)
    @seed.error "Resource path #{path.inspect} is not a file." unless File.file?(path)
    path
  end

end
