class AutoInputMarkupComments < AutoInputBase

  # Auto input example: 
  #   markup_comments:
  #     - only: phase_a
  #       users:    [read_1, read_2, read_3]
  #       comments: 3       #=> number of comments to auto-generate
  #       nested:   true    #=> nest the comments; e.g. comment text suffixed with: '1.1.', '1.1.1.', '1.1.1.1', ...

  def process(options)
    @num_coms        = options[:comments] || 1
    @nested          = options[:nested]   || false
    @not_from_users  = [options[:not_from_users]].flatten.compact
    @not_from_teams  = [options[:not_from_teams]].flatten.compact
    @not_to_users    = [options[:not_to_users]].flatten.compact
    @not_to_teams    = [options[:not_to_teams]].flatten.compact
    @discussionables = [options[:discussionables]].flatten.compact
    @values          = [options[:comment_values]].flatten.compact
    @phases          = selected_phases
    error "Markup comments phases are blank." if @phases.blank?
    add_comments
  end

  def add_comments
    case
    when @discussionables.present?  then add_discussionable_comments
    when @phases.present?           then add_phase_comments
    else error "Invalid options for markup comments."
    end
  end

  def add_discussionable_comments
    @phases.each do |phase|
      @discussionables.each do |discussionable|
        add_discussionable_ownerable_comments(phase, discussionable)
      end
   end
  end

  def add_phase_comments; @phases.each {|phase| add_discussionable_ownerable_comments(phase, phase)}; end

  def add_discussionable_ownerable_comments(phase, discussionable)
    not_creators   = get_not_creators(phase)
    not_ownerables = get_not_ownerables(phase)
    creators       = get_phase_users(phase).sort_by {|r| r.title}
    ownerables     = get_phase_ownerables(phase).sort_by {|r| r.title}
    creators.each do |creator|
      next if not_creators.include?(creator)
      next if discussionable.respond_to?(:ownerable) && discussionable.ownerable == creator # don't comment to self
      ownerables.each do |ownerable|
        next if ownerable == creator # don't comment to self
        next if not_ownerables.include?(ownerable)
        add_comment(phase, discussionable, creator, ownerable)
      end
    end
  end

  def get_not_creators(phase);   get_not_records(phase, @not_from_users, @not_from_teams); end
  def get_not_ownerables(phase); get_not_records(phase, @not_to_users,   @not_to_teams); end

  def get_not_records(phase, user_names, team_titles)
    return Array.new if user_names.blank? && team_titles.blank?
    users = user_names.map {|u| find_user_by_name(u)}
    return users if team_titles.blank?
    all_teams = get_phase_teams(phase, @options)
    teams     = all_teams.select {|t| team_titles.include?(t.title)}
    users + teams
  end

  def add_comment(authable, discussionable, creator, ownerable)
    options = {
      user:           creator,
      authable:       authable,
      ownerable:      ownerable,
      creatorable:    creator,
      discussionable: discussionable,
    }
    authable == discussionable ? add_phase_comment(options) : add_discussionable_comment(options)
  end

  def add_phase_comment(options)
    creator    = options[:user]
    discussion = find_or_create_discussion(options)
    options.merge!(
      discussion:    discussion,
      commenterable: creator,
    )
    name      = creator_comment_name(options)
    comment   = nil
    @coms_pos = discussion.thinkspace_markup_comments.where(parent_id: nil).maximum(:position) || 0
    @num_coms.times do |i|
      text, pid, pos = get_comment_text(name, comment)
      comment        = create_comment(options.merge(comment: text, parent_id: pid, position: pos))
    end
  end

  def add_discussionable_comment(options)
    creator        = options[:user]
    discussionable = options[:discussionable]
    name           = creator_comment_name(options)
    comment        = nil
    @coms_pos      = 0
    @num_coms.times do |i|
      opts         = options.dup
      opts[:value] = get_discussion_value(options, i)
      discussion   = find_or_create_discussion(opts)
      opts.merge!(
        discussion:    discussion,
        commenterable: creator,
      )
      text, pid, pos = get_comment_text(name, comment)
      comment        = create_comment(opts.merge(comment: text, parent_id: pid, position: nil))
    end
  end

  # Try not to overlay comments (shift right if same position).
  def get_discussion_value(options, i)
    value          = (@values[i] || {x: 0, y: 0, page: 1 }).deep_symbolize_keys
    discussionable = options[:discussionable]
    ownerable      = options[:ownerable]
    discussions    = discussion_class.where(discussionable: discussionable, ownerable: ownerable)
    x = value[:x]
    y = value[:y]
    p = value[:page]
    discussions.each do |discussion|
      dv  = (discussion.value || Hash.new).deep_symbolize_keys
      pos = dv[:position] || Hash.new
      dx  = pos[:x]
      dy  = pos[:y]
      dp  = pos[:page]
      case
      when dx == x && dy == y && dp == p  then x += 50; y += 50
      end
    end
    {position: {x: x, y: y, page: p}}
  end

  def get_comment_text(name, comment)
    unless nested?
      @coms_pos += 1
      text       = "[#{name}] Auto-Comment #{@coms_pos}."
      return [text, nil, @coms_pos]
    end
    pid  = nil
    pos  = nil
    text = ''
    if comment.blank?
      @ci        = [1]
      pid        = nil
      @coms_pos += 1
      pos        = @coms_pos + 0
    else
      pid = comment.id
      pos = 1
      @ci.push(1)
    end
    cid  = @ci.join('.')
    text = "[#{name}] Auto-Comment #{@coms_pos}.#{cid}."
    [text, pid, pos]
  end

  def nested?; @nested == true; end

  def create_comment(options)
    comment = @seed.new_model(:markup, :comment, options)
    @seed.create_error(comment)  unless comment.save
    comment
  end

  def find_or_create_discussion(options)
    scope      = discussion_class.where(options.except(:user, :value))
    table_name = discussion_class.table_name
    tbl_value  = "#{table_name}.value"
    if (value  = options[:value]).present?
      position   = value['position'] || {}
      scope      = scope.where("#{tbl_value} ->> 'position' = '#{position}'")
    else
      scope = scope.where("#{tbl_value}::text = '{}'::text")
    end
    discussion = scope.first
    return discussion if discussion.present?
    discussion = @seed.new_model(:markup, :discussion, options)
    @seed.create_error(discussion)  unless discussion.save
    discussion
  end

  def creator_comment_name(options)
    from = options[:creatorable]
    to   = options[:ownerable]
    dfor = options[:discussionable]
    name = 'from ' + (from.respond_to?(:first_name) ? from.first_name : from.title)
    name += ' to '  + (to.respond_to?(:first_name) ? to.first_name : to.title)
    name += " for #{dfor.attachment_file_name}"  if dfor.present? && dfor.respond_to?(:attachment_file_name)
    name
  end

  def comment_class;         @_comment_class         ||= @seed.model_class(:markup, :comment); end
  def discussion_class;      @_discussion_class      ||= @seed.model_class(:markup, :discussion); end

end
