#########################################################################################
# ###
# ### Readiness Assurance Phase Componentable.
# ###
def casespace_seed_config_add_readiness_assurances(config)
  array = config.dig(:readiness_assurance, :assessments)
  return if array.blank?
  ra_hash = (@_readiness_assurance_assessments_ ||= Hash.new)
  [array].flatten.compact.each do |options|
    CreateReadinessAssuranceAssessments.new(self, @seed, ra_hash, config, options)
  end
end

def create_casespace_phase_componentable_readiness_assurance(phase, section, common_component, config)
  return if phase.settings.dig('readiness_assurance', 'trat_overview') == true
  if @_readiness_assurance_assessments_.blank?
    message  = "Readiness assurance 'casespace_seed_config_get_config_methods' did not run 'casespace_seed_config_add_readiness_assurances'.\n"
    message += 'Is the readiness_assurance gem included and listed in the thinkspace.config.yml paths?'
    @seed.error(message)
  end
  assessment = @_readiness_assurance_assessments_.delete(phase.id)
  @seed.error "Readiness assurance assessment for phase id #{phase.id} is blank."  if assessment.blank?
  assessment
end


class CreateReadinessAssuranceAssessments

  def initialize(caller, seed, ra_hash, config, options={})
    @caller  = caller
    @seed    = seed
    @ra_hash = ra_hash
    @config  = config
    process(options)
  end

  def process(options={})
    @assessment_class = @seed.model_class(:readiness_assurance, :assessment)
    space             = get_space(options[:space])
    assignment        = get_assignment(space, options[:assignment])
    phases            = get_phases(assignment, options[:phases])
    user              = get_user(options[:user])
    phases.each do |phase|
      @seed.error "Readiness assurance assessment for phase #{phase.title.inspect} already exists."  if @ra_hash.has_key?(phase.id)
      hash = options[:assessment].deep_dup
      @seed.error "Readiness assurance assessments auto-input requires an assessment hash." if hash.blank? or !hash.is_a?(Hash)
      title              = hash[:title] || "ra assessment for phase id #{phase.id}"
      hash[:authable]    = phase
      hash[:user]        = user
      hash[:title]       = title
      hash[:state]       = :active  unless hash.has_key?(:state)
      assessment         = create_assessment(hash)
      @ra_hash[phase.id] = assessment
      @caller.casespace_config_models.add(@config, assessment)
    end
  end

  def create_assessment(hash)
    questions = hash[:questions] || []
    questions = questions.flatten
    answers   = hash[:answers] || {}
    answers   = (answers.first || {}) if answers.is_a?(Array)
    hash[:questions] = questions
    hash[:answers]   = answers
    @caller.send :create_readiness_assurance_assessment, hash
  end

  def get_space(title)
    @seed.error "Readiness assurance assessments auto-input requires a space."  if title.blank?
    space = @caller.find_casespace_space(title: title)
    @seed.error "Readiness assurance space #{title.inspect} not found."  if space.blank?
    space
  end

  def get_assignment(space, title)
    @seed.error "Readiness assurance assessments auto-input requires an assignment."  if title.blank?
    assignment = @caller.find_casespace_assignment(title: title, space_id: space.id)
    @seed.error "Readiness assurance assignment #{title.inspect} not found."  if assignment.blank?
    assignment
  end

  def get_user(name)
    @seed.error "Readiness assurance assessments auto-input requires a user."  if name.blank?
    user = @caller.find_casespace_user(first_name: name)
    @seed.error "Readiness assurance user #{name.inspect} not found."  if user.blank?
    user
  end

  def get_phases(assignment, titles)
    @seed.error "Readiness assurance assessments auto-input requires phases."  if titles.blank?
    phases = Array.new
    [titles].flatten.compact.each do |title|
      phase = @caller.find_casespace_phase(title: title, assignment_id: assignment.id)
      @seed.error "Readiness assurance phase #{title.inspect} not found."  if phase.blank?
      phases.push(phase)
    end
    phases
  end

end
