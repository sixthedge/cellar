class AutoInputPathItems < AutoInputBase

  def process(options)
    count = options[:count]
    paths = @seed.model_class(:diagnostic_path, :path).all.order(:id)
    paths.each do |path|
      phase = path.authable
      next unless include_model?(phase)
      lists = @seed.model_class(:observation_list, :list).where(authable: phase).order(:id)
      if lists.present? && options[:list] != false
        auto_populate_diagnostic_path_from_observation_lists(phase, path, lists, options, count)
      else
        auto_populate_diagnostic_path_without_itemables(phase, path, options, count)
      end
    end
    # debug_diagnostic_path_path_items
  end

  def auto_populate_diagnostic_path_without_itemables(phase, path, options, count)
    return if count.blank?
    get_casespace_phase_ownerables(phase).each do |ownerable|
      auto_populate_diagnostic_path_path_items(path, ownerable, [], options, count)
    end
  end

  def auto_populate_diagnostic_path_from_observation_lists(phase, path, lists, options, count)
    ownerables         = get_phase_ownerables(phase)
    list_ids_processed = Array.new  # since lists have lists don't reprocess 
    lists.each do |list|
      next if list_ids_processed.include?(list.id)
      list_lists          = @seed.get_association(list, :observation_list, :lists).order(:id).select {|l| !list_ids_processed.include?(l.id)}
      list_ids            = list_lists.map(&:id)
      list_ids_processed += list_ids
      ownerables.each do |ownerable|
        observations = @seed.model_class(:observation_list, :observation).where(ownerable: ownerable, list_id: list_ids).order(:id).to_a
        next if observations.blank?
        item_count = count.present? ? count : observations.length
        auto_populate_diagnostic_path_path_items(path, ownerable, observations, options, item_count)
      end
    end
  end

  def auto_populate_diagnostic_path_path_item(options, hash)
    path        = hash[:path]
    parent_id   = hash[:parent].present? ? hash[:parent].id : 'none'
    ownerable   = hash[:ownerable]
    itemable    = hash[:path_itemable]
    format_col  = path.authable.team_ownerable? ? :title : (options[:user_format_col] || :first_name)
    description = '[item]'
    description += " #{format_ownerable(ownerable, format_col)}"
    description += " Parent(#{parent_id})"
    if itemable.present?
      description += " Itemable(#{itemable.class.name.demodulize}:#{itemable.id})"
    end
    description += " Ownerable(#{ownerable.class.name.demodulize}:#{ownerable.id})"
    create_diagnostic_path_path_item(hash.merge(description: description))
  end

  def auto_populate_diagnostic_path_path_item_children(pattern, parents, itemables, item_hash, options, count, running_count=0)
    number_of = pattern.shift
    return if number_of.blank? || parents.blank? || (count.present? && running_count >= count)
    new_parents = Array.new
    number_of.times do |index|
      parents.each do |parent|
        running_count += 1
        next if count.present? && running_count > count
        hash = item_hash.merge(parent: parent, position: index, path_itemable: itemables.shift)
        new_parents.push auto_populate_diagnostic_path_path_item(options, hash)
      end
    end
    auto_populate_diagnostic_path_path_item_children(pattern, new_parents, itemables, item_hash, options, count, running_count)
  end

  def auto_populate_diagnostic_path_path_items(path, ownerable, itemables, options, item_count, start_position=0)
    return if item_count.blank? || item_count < 1
    pattern           = get_paths_item_pattern(options)
    user_id           = path.authable.team_ownerable? ? 1 : ownerable.id
    items_per_pattern = get_total_paths_items_from_pattern(pattern)

    top_level_count   = item_count / items_per_pattern
    top_level_count   = 1  if top_level_count < 1
    top_level_count  += 1  if (top_level_count * items_per_pattern) < item_count

    total_count = top_level_count * items_per_pattern
    add_count   = total_count < item_count ? item_count - total_count : 0

    item_hash = {
      path:          path,
      user_id:       user_id,
      ownerable:     ownerable,
      path_itemable: nil,
      parent:        nil,
      position:      0,
    }

    top_level_items = Array.new
    top_level_count.times do |index|
      hash = item_hash.merge(position: start_position + index, path_itemable: itemables.shift)
      top_level_items.push auto_populate_diagnostic_path_path_item(options, hash)
    end

    child_count = item_count - top_level_count
    auto_populate_diagnostic_path_path_item_children(pattern, top_level_items, itemables, item_hash, options, child_count)  if child_count > 0

    if add_count > 0
      auto_populate_diagnostic_path_path_items(path, ownerable, itemables, options, add_count, top_level_items.length)
    end

  end

  def get_paths_item_pattern(options)
    [options[:pattern] || 0].flatten.deep_dup # [#children, #grand_children, ...] => defaults to no children
  end

  def get_total_paths_items_from_pattern(pattern)
    items = []
    pattern.each_with_index do |count, index|
      index == 0 ? items.push(count) : items.push(count * items[index-1])
    end
    items.sum + 1
  end

  # ###
  # ### Debug.
  # ###

  def debug_diagnostic_path_path_items(ownerable_id=1)
    puts "\n"
    klass = @seed.model_class(:diagnostic_path, :path_item)
    total = klass.where(ownerable_id: ownerable_id).count
    puts "Total Path Items=#{total}\n"
    pad     = 0
    parents = klass.all.where(parent_id: nil, ownerable_id: ownerable_id).order(:position)
    parents.each do |parent|
      debug_diagnostic_path_path_item_line(parent, pad, line='=parent ')
      debug_diagnostic_path_path_item_children(klass, ownerable_id, parent, pad)
    end
    puts "\n"
  end

  def debug_diagnostic_path_path_item_children(klass, ownerable_id, parent, pad)
    return if parent.blank?
    items = klass.where(ownerable_id: ownerable_id, parent_id: parent.id).order(:position)
    pad  += 1
    items.each do |item|
      debug_diagnostic_path_path_item_line(item, pad)
      debug_diagnostic_path_path_item_children(klass, ownerable_id, item, pad)
    end
  end

  def debug_diagnostic_path_path_item_line(item, pad, line='')
    indent = '    ' * pad
    puts line + indent + "#{item.position}: id=#{item.id}  itemable=#{item.path_itemable_type}.#{item.path_itemable_id}"
  end

end # AutoInputDiagnosticPaths
