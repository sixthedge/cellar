#########################################################################################
# ###
# ### Peer Assessment Phase Componentable.
# ###

def create_casespace_phase_componentable_peer_assessment(phase, section, common_component, config={})
  case common_component.title
  when 'peer-assessment'
    value = config[:value]
    @seed.error "Peer evaluation config[:value] is blank." if value.blank?
    state           = config[:state]
    options         = {authable: phase, value: value}
    options[:state] = state if state.present?
    comp = create_peer_assessment_assessment(options)
  when 'peer-assessment-overview'
    assessment = casespace_peer_assessment_get_assessment_for_overview(config)
    comp = create_peer_assessment_overview authable: phase, assessment_id: assessment.id
  else
    @seed.error "Peer evaluation common component title #{common_component.title.inspect} is unknown."
  end
  comp
end

def casespace_peer_assessment_get_assessment_for_overview(config)
  title = config[:phase]
  @seed.error "Peer evaluation overview phase is blank." if title.blank?
  phase = find_casespace_phase(title: title)
  @seed.error "Peer evaluation overview phase #{title.inspect} not found."  if phase.blank?
  assessment_class = @seed.model_class(:peer_assessment, :assessment)
  phase_component  = @seed.get_association(phase, :casespace, :phase_components).where(componentable_type: assessment_class.name).first
  @seed.error "Peer evalutaion overview phase #{title.inspect} does not have an peer evaluation assessment phase component."  if phase_component.blank?
  assessment = phase_component.componentable
  @seed.error "Peer evalutaion overview phase #{title.inspect} assessment is blank."  if assessment.blank?
  assessment
end
