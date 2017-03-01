class AutoInputIndentedListResponses < AutoInputBase

  def process(options)
    username = options[:expert]
    if username.blank?
      process_non_expert(options)
    else
      process_expert(username, options)
    end
  end

  def process_non_expert(options)
    count = options[:count]
    lists = @seed.model_class(:indented_list, :list).all.order(:id)
    lists.each do |list|
      phase = list.authable
      next unless include_model?(phase)
      olists = @seed.model_class(:observation_list, :list).where(authable: phase).order(:id)
      if olists.present? && options[:observation_list] != false
        populate_from_observation_lists(phase, list, olists, options, count)
      else
        populate_without_itemables(phase, list, options, count)
      end
    end
  end

  def process_expert(username, options)
    user = find_user_by_name(username)
    error "Indented list expert user #{expert.inspect} not found"  if user.blank?
    count      = options[:count]
    title      = options[:phase]
    list_class = @seed.model_class(:indented_list, :list)
    error "Indented list expert hash must contain a phase title #{options.inspect}"  if title.blank?
    phase = find_phase_by_title(title)
    error "Indented list expert hash phase title #{title.inspect} not found."  if phase.blank?
    phase_component = @seed.get_association(phase, :casespace, :phase_components).find_by(componentable_type: list_class.name)
    error "Indented list expert hash phase title #{title.inspect} does not have an indented list component."  if phase_component.blank?
    list         = phase_component.componentable
    orig_list_id = list.settings['list_id']
    error "Indented list expert settings 'list_id' is blank #{list.inspect}."  if orig_list_id.blank?
    response = @seed.model_class(:indented_list, :response).find_by(list_id: orig_list_id, ownerable: user)
    if options[:observation_list] != false
      error "Indented list expert #{username.inspect} does not have a response for list [id: #{orig_list_id}]\n  List: #{list.inspect}."  if response.blank?
      puts "[WARNING] Indented list expert is poplulated from #{username.inspect} and 'count' value ignored."  if options[:count].present?
      puts "[WARNING] Indented list expert is poplulated from #{username.inspect} and 'indent' value ignored."  if options[:indent].present?
      populate_expert_response(phase, list, user, response, options)
    else
      populate_without_itemables(phase, list, options, count)
    end
  end

  def populate_without_itemables(phase, list, options, count)
    return if count.blank?
    get_phase_ownerables(phase).each do |ownerable|
      add_response_for_ownerable(list, ownerable, [], options, count)
    end
  end

  # ###
  # ### ExpertResponses.
  # ###

  def populate_expert_response(phase, list, user, response, options)
    items     = (response.value || Hash.new)['items']
    orig_list = @seed.get_association(response, :indented_list, :list)
    error "Indened list response [id: #{response.id}] list not found."  if orig_list.blank?
    expert_items = Array.new
    items.each do |item|
      eitem = item.symbolize_keys.except(:itemable_id, :itemable_type, :itemable_value_path)
      add_item_itemable_values(item, eitem)
      expert_items.push(eitem)
    end
    state = options[:state] || :active
    expert_hash  = {
      user:     user,
      list:     list,
      response: response,
      state:    state,
      value:    {items: expert_items},
    }
    create_expert_response(expert_hash, options)
  end

  def add_item_itemable_values(item, new_item)
    id       = item['itemable_id']
    type     = item['itemable_type']
    itemable = nil
    klass    = nil
    if type.present?
      error "Indented list itemable id is blank #{item.inspect}."  if id.blank?
      class_name = type.classify
      klass      = class_name.safe_constantize
      error "Indented list itemable class #{class_name.inspect} could not be constantized."  if klass.blank?
      itemable = klass.find_by(id: id)
      error "Indented list itemable class #{class_name.inspect} [id: #{id}] not found."  if itemable.blank?
    end
    if itemable.present?
      description, icon = get_itemable_values(itemable)
    else
      id   ||= 'none'
      type ||= 'unknown'
      description = "auto: #{type}.#{id}"
      icon = nil
    end
    new_item[:description] = description
    new_item[:icon]        = icon  if icon.present?
  end

  def get_itemable_values(itemable)
    description = itemable.value  if itemable.respond_to?(:value)
    icon        = get_itemable_icon(itemable)
    [description, icon]
  end

  def get_itemable_icon(itemable)
    icon = 'unknown'
    case
    when itemable.is_a?(@seed.model_class(:observation_list, :observation))
      list = @seed.get_association(itemable, :observation_list, :list)
      cat  = (list.category || Hash.new)['name']
      icon = convert_icon_category_to_id(cat)
    end
    icon
  end

  def convert_icon_category_to_id(cat)
    case (cat || '').downcase.to_sym
    when :d   then :lab
    when :h   then :html
    when :m   then :mechanism
    else
      'none'
    end
  end

  # ###
  # ### Responses.
  # ###

  def populate_from_observation_lists(phase, list, olists, options, count)
    ownerables          = get_phase_ownerables(phase)
    olist_ids_processed = Array.new  # since lists have lists don't reprocess 
    olists.each do |olist|
      next if olist_ids_processed.include?(olist.id)
      olist_lists          = @seed.get_association(olist, :observation_list, :lists).order(:id).select {|l| !olist_ids_processed.include?(l.id)}
      olist_ids            = olist_lists.map(&:id)
      olist_ids_processed += olist_ids
      ownerables.each do |ownerable|
        observations = @seed.model_class(:observation_list, :observation).where(ownerable: ownerable, list_id: olist_ids).order(:id).to_a
        next if observations.blank?
        item_count = count.present? ? count : observations.length
        add_response_for_ownerable(list, ownerable, observations, options, item_count)
      end
    end
  end

  def add_response_for_ownerable(list, ownerable, itemables, options, item_count)
    value  = Hash.new
    items  = value[:items] = Array.new
    pos_x  = 0
    indent = get_indent(options)
    item_count.times do |y|
      pos_x    = 0  if pos_x >= indent
      itemable = itemables[y]
      hash     = {pos_y: y, pos_x: pos_x}
      if itemable.present?
        hash[:itemable_id]         = itemable.id
        hash[:itemable_type]       = itemable.class.name
        hash[:itemable_value_path] = 'value'
        hash[:icon]                = get_itemable_icon(itemable)
      else
        hash[:description] = "auto: (#{y}:#{pos_x}) #{list.title}"
      end
      items.push(hash)
      pos_x += 1
    end
    response_hash = {
      list:      list,
      user_id:   list.authable.team_ownerable? ? 1 : ownerable.id,
      ownerable: ownerable,
      value:     value,
    }
    create_response(response_hash, options)
  end

  # ###
  # ### Helpers.
  # ###

  def create_response(hash, options)
    @caller.send :create_indented_list_response, hash
  end

  def create_expert_response(hash, options)
    @caller.send :create_indented_list_expert_response, hash
  end

  def get_indent(options); options[:indent] || 0; end

end # AutoInputIndentedListItems class
