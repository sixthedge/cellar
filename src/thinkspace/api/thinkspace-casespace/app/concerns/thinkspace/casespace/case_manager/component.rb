module Thinkspace; module Casespace; module CaseManager; class Component

  # from init options
  attr_reader :phase_template
  attr_reader :tag
  attr_reader :section
  attr_reader :title
  attr_reader :attributes

  # set by this class
  attr_reader :create_order
  attr_reader :common_component

  def initialize(phase_template, component)
    @phase_template = phase_template
    @tag            = component.to_s
    @attributes     = Hash.from_xml(tag).with_indifferent_access[:component] || Hash.new
    @title          = attributes.delete(:title)
    @section        = attributes.delete(:section) || title
    @create_order   = get_create_order
  end

  def get_create_order
    case section
    when 'header'  then 1
    when 'submit'  then 99
    else 10
    end
  end

  # ###
  # ### Create Componentable and Phase Component.
  # ###

  def create(phase)
    validate  # basic validate incase was not called before the create
    raise_create_error "phase is blank" if phase.blank?
    phase_component = phase_component_class.new(
      component_id: common_component.id,
      phase_id:     phase.id,
      section:      section,
    )
    phase_component.componentable = create_componentable(phase)
    raise_create_error "error saving phase component" unless phase_component.save
    phase_component
  end

  def create_componentable(phase)
    componentable_model(phase, get_componentable_model_path)
  end

  def componentable_model(phase, model_path)
    method      = :create_componentable
    model_class = model_path.classify
    klass       = model_class.safe_constantize
    return phase if phase.is_a?(klass)  # could add a phase method to return the phase param
    raise_create_error "could not constantize #{model_class.inspect}"  if klass.blank?
    raise_create_error "model #{model_class.inspect} does not respond to #{method}"  unless klass.respond_to?(method)
    klass.send method, phase
  end

  def get_componentable_model_path
    case title
    when 'artifact-bucket'
      'thinkspace/artifact/bucket'
    when 'casespace-phase-header', 'casespace-phase-submit'
      'thinkspace/casespace/phase'
    when 'diagnostic-path-viewer', 'diagnostic-path-viewer-ownerable'
      'thinkspace/diagnostic_path_viewer/viewer'
    when 'diagnostic-path'
      'thinkspace/diagnostic_path/path'
    when 'html', 'html-only', 'html-select-text'
      'thinkspace/html/content'
    when 'lab'
      'thinkspace/lab/chart'
    when 'observation-list'
      'thinkspace/observation_list/list'
    when 'weather-forecaster'
      'thinkspace/weather_forecaster/assessment'
    when 'peer-assessment'
      'thinkspace/peer_assessment/assessment'
    when 'peer-assessment-overview'
      'thinkspace/peer_assessment/assessment'
    when 'simulation'
      'thinkspace/simulation/simulation'
    else
      raise_error "unknown componentable model path for #{title.inspect}"
    end
  end

  # ###
  # ### Validate.
  # ###

  def validate
    raise_validation_error "title is blank"    if title.blank?
    raise_validation_error "section is blank"  if section.blank?
    @common_component = common_component_class.find_by(title: title)
    raise_validation_error "is not a common component"  if common_component.blank?
  end

  def validate_references(sections=[])
    get_section_references.each do |section|
      raise_validation_error "section reference #{section.inspect} not defined in the template" unless sections.include?(section)
    end
  end

  # ###
  # ### Helpers.
  # ###

  def get_section_references
    references = Array.new
    attributes.each do |key, value|
      next if key.start_with?('data')  # skip data attributes
      if value.present?
        next if value == 'true' || value == 'false'  # if a boolean, then is not a reference to another section
        values      = value.split(' ').select {|v| v.present?}.map {|v| v.strip}
        references += values
      end
    end
    references
  end

  def common_component_class; Thinkspace::Common::Component; end
  def phase_component_class;  Thinkspace::Casespace::PhaseComponent; end

  def error_message(message); "Phase template id #{phase_template.id} " + message + " [tag: #{tag}]"; end

  def raise_validation_error(message)
    raise ValidationError, error_message(message)
  end

  def raise_create_error(message)
    raise CreateError, error_message(message)
  end

  class CreateError < StandardError; end
  class ValidationError < StandardError; end

end; end; end; end
