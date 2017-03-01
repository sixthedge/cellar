class AutoInputMarkupLibrary < AutoInputBase

  def process(options)
    @num_lib_coms = options[:comments] || 3
    @lib_tags     = options[:tags] || []
    process_spaces
  end

  def process_spaces
    selected_spaces.each do |space|
      users = get_space_users(space)
      process_users(users)
    end
  end

  def process_users(users)
    users.each do |user|
      lib      = find_or_create_library(user)
      lib_coms = find_or_create_library_comments(lib, user)
    end
  end

  def find_or_create_library(user)
    lib = library_class.find_by(user_id: user.id)
    return lib if lib.present?
    lib  = @seed.new_model(:markup, :library, user_id: user.id)
    tags = @lib_tags.deep_dup
    tags += ['Tag X']  if @num_lib_coms > tags.length  # add default if more comments than tags
    add_tags(lib, tags)
    @seed.create_error(lib)  unless lib.save
    lib
  end

  def find_or_create_library_comments(lib, user)
    lib_coms = library_comment_class.where(user_id: user.id)
    return lib_coms if lib_coms.present?
    lib_coms = Array.new
    tags     = @lib_tags.deep_dup
    @num_lib_coms.times do |i|
      tag     = tags.shift || 'Tag X'
      comment = "[#{user.first_name}] Comment #{i+1}."
      lib_com = @seed.new_model(:markup, :library_comment, library_id: lib.id, user_id: user.id, comment: comment)
      add_tags(lib_com, tag)
      @seed.create_error(lib_com)  unless lib_com.save
      lib_coms.push(lib_com)
    end
    lib_coms
  end

  def add_tags(rec, tags)
    all_tags = [tags].flatten.compact.sort.uniq
    all_tags.each do |tag|
      rec.tag_list.add(tag)
    end
  end

  def library_class;         @_library_class         ||= @seed.model_class(:markup, :library); end
  def library_comment_class; @_library_comment_class ||= @seed.model_class(:markup, :library_comment); end

end
