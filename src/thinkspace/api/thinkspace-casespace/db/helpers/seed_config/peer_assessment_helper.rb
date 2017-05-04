#########################################################################################
# ###
# ### Peer Assessment Phase Componentable.
# ###
def casespace_seed_config_add_peer_assessments(config)
  array = config.dig(:peer_assessment, :assessments)
  return if array.blank?
  pe_hash = (@_peer_assessment_assessments_ ||= Hash.new)
  [array].flatten.compact.each do |options|
    CreatePeerAssessmentAssessments.new(self, @seed, pe_hash, config, options)
  end
end

def create_casespace_phase_componentable_peer_assessment(phase, section, common_component, config={})
  if @_peer_assessment_assessments_.blank?
    message  = "Peer assessment 'casespace_seed_config_get_config_methods' did not run 'casespace_seed_config_add_peer_assessments'.\n"
    message += 'Is the peer_assessment gem included and listed in the thinkspace.config.yml paths?'
    @seed.error(message)
  end
  assessment = @_peer_assessment_assessments_.delete(phase.id)
  @seed.error "Peer assessment assessment for phase id #{phase.id} is blank."  if assessment.blank?
  assessment
end

class CreatePeerAssessmentAssessments

  def initialize(caller, seed, pe_hash, config, options={})
    @caller  = caller
    @seed    = seed
    @pe_hash = pe_hash
    @config  = config
    process(options)
  end

  def process(options={})
    @assessment_class = @seed.model_class(:peer_assessment, :assessment)
    space             = get_space(options[:space])
    assignment        = get_assignment(space, options[:assignment])
    phases            = get_phases(assignment, options[:phases])
    user              = get_user(options[:user])
    phases.each do |phase|
      @seed.error "Peer assessment assessment for phase #{phase.title.inspect} already exists."  if @pe_hash.has_key?(phase.id)
      hash = options[:assessment].deep_dup
      @seed.error "Peer assessment assessments auto-input requires an assessment hash." if hash.blank? or !hash.is_a?(Hash)
      title              = hash[:title] || "pe assessment for phase id #{phase.id}"
      hash[:authable]    = phase
      hash[:user]        = user
      hash[:title]       = title
      hash[:state]       = :active  unless hash.has_key?(:state)
      assessment         = create_assessment(hash)
      @pe_hash[phase.id] = assessment
      @caller.casespace_config_models.add(@config, assessment)
    end
  end

  def create_assessment(hash)
    @caller.send :create_peer_assessment_assessment, hash
  end

  def get_space(title)
    @seed.error "Peer assessment assessments auto-input requires a space."  if title.blank?
    space = @caller.find_casespace_space(title: title)
    @seed.error "Peer assessment space #{title.inspect} not found."  if space.blank?
    space
  end

  def get_assignment(space, title)
    @seed.error "Peer assessment assessments auto-input requires an assignment."  if title.blank?
    assignment = @caller.find_casespace_assignment(title: title, space_id: space.id)
    @seed.error "Peer assessment assignment #{title.inspect} not found."  if assignment.blank?
    assignment
  end

  def get_user(name)
    @seed.error "Peer assessment assessments auto-input requires a user."  if name.blank?
    user = @caller.find_casespace_user(first_name: name)
    @seed.error "Peer assessment user #{name.inspect} not found."  if user.blank?
    user
  end

  def get_phases(assignment, titles)
    @seed.error "Peer assessment assessments auto-input requires phases."  if titles.blank?
    phases = Array.new
    [titles].flatten.compact.each do |title|
      phase = @caller.find_casespace_phase(title: title, assignment_id: assignment.id)
      @seed.error "Peer assessment phase #{title.inspect} not found."  if phase.blank?
      phases.push(phase)
    end
    phases
  end

end