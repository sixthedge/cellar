#########################################################################################
# ###
# ### Observation List Phase Componentable.
# ###
def create_casespace_phase_componentable_observation_list(phase, section, common_component, config)
  category = config[:category] || {name: get_casespace_phase_componentable_observation_list_category_name(phase)}
  create_observation_list authable: phase, category: category
end

# Set the category name based on the other components defined in the phase template.
# Using a 'match' so may not be 100% accruate but should be correct most of the time
# or can add in the phase's sections: {obs-list: {category: H|D|M}.
# diagnostic-path = 'M'; lab = 'D'; html = 'H'
def get_casespace_phase_componentable_observation_list_category_name(phase)
  phase_template = @seed.get_association(phase, :casespace, :phase_template)
  template       = phase_template.template || ''
  case
  when template.match('diagnostic-path') then 'M'
  when template.match('lab')             then 'D'
  when template.match('html')            then 'H'
  else
    'H'  # default
  end
end

#########################################################################################
# ###
# ### Post Phase Componentables.
# ###

# Called after all phase components have been created.
# Currently does not support observation list sub-groups in an assignment.
# To implement sub-groups, would need to collect configs above and get group(s) from configs and pass as group_lists.
def post_casespace_phase_componentables_observation_list
  phase_component_class = @seed.model_class(:casespace, :phase_component)
  list_class            = @seed.model_class(:observation_list, :list)
  assignments           = casespace_get_assignments_created
  assignments.each do |assignment|
    observation_lists = Hash.new
    phase_ids         = @seed.get_association(assignment, :casespace, :phases).pluck(:id)
    phase_components  = phase_component_class.where(phase_id: phase_ids, componentable_type: list_class.name)
    phase_components.each do |phase_component|
      observation_list       = phase_component.componentable
      key                    = observation_list.id.to_s
      phase                  = @seed.get_association(phase_component, :casespace, :phase)
      observation_lists[key] = {title: phase.title, observation_lists: observation_list}
    end
    if observation_lists.present?
      @seed.message "++Adding phase observation list groups for assignment #{assignment.title.inspect}."
      add_casespace_phase_observation_list_groups(assignment, observation_lists)
    end
  end
end

# Add any observation list groups and list associations.
# The phase_observation_lists is a hash where hash[key] = {title: 'title', observation_lists: [observation_list-instances] || observation_list-instance}.
# The group_lists is an array of arrays where each array contains the keys to combine the lists.
def add_casespace_phase_observation_list_groups(assignment, phase_observation_lists={}, group_lists=[])
  group_lists = [phase_observation_lists.keys]  if group_lists.blank?  # default to one group for the assignment's phases
  return if group_lists.blank?  # no lists on the phases
  group_lists.each do |group_keys|
    hashes = group_keys.collect {|key| phase_observation_lists[key] || Hash.new}
    titles = hashes.collect {|h| h[:title]}.compact
    next if titles.blank?  # has group keys but phase(s) do not have observation lists
    group = create_observation_list_group(
      title:     titles.join(' '),
      groupable: assignment,
    )
    lists = hashes.collect {|h| h[:observation_lists]}
    create_observation_list_group_lists(group, lists)
  end
end
