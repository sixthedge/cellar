require 'nokogiri'
module Thinkspace; module Casespace; module CaseManager; class PhaseTemplate

  attr_reader :phase_template_id

  def set_phase_template_id(args)
    @phase_template_id = ENV['phase_template_id']
    # @phase_template_id = args.first
    raise_error "No phase template id in args."  if phase_template_id.blank?
    raise_error "Phase template id #{phase_template_id.inspect} must be a number."  unless phase_template_id.to_s.match(/^\d+$/)
  end

  def process(args)
    set_phase_template_id(args)
    phase_template = get_phase_template
    components     = get_components(phase_template)
    validate_components(components)
    sorted_components = components.sort_by {|comp| comp.create_order}
    phase = get_phase
    phase.transaction do
      sorted_components.each do |component|
        component.create(phase)
      end

      raise '------testing rollback--------'
    end
  end

  def get_phase
    phase = phase_class.first
    raise_error "Phase not found."  if phase.blank?
    phase
  end

  def get_phase_template
    phase_template = phase_template_class.find_by(id: phase_template_id)
    raise_error "Phase template id #{phase_template_id} not found."  if phase_template.blank?
    phase_template
  end

  def get_components(phase_template)
    template = phase_template.template
    raise_error "Phase template id #{id} template is blank."  if template.blank?
    doc   = Nokogiri::HTML.fragment(template)
    comps = doc.css('component')
    comps.map {|comp| Component.new(phase_template, comp)}
  end

  # ###
  # ### Validate Components.
  # ###

  def validate_components(components)
    components.each {|component| component.validate}
    sections = get_all_template_sections(components)
    components.each {|component| component.validate_references(sections)}
  end

  def get_all_template_sections(components)
    sections   = Array.new
    components.each do |component|
      section = component.section
      component.raise_validation_error "section #{section.inspect} is a duplicate"  if sections.include?(section)
      sections.push(section)
    end
    sections
  end

  def phase_class;          Thinkspace::Casespace::Phase; end
  def phase_template_class; Thinkspace::Casespace::PhaseTemplate; end

  def raise_error(message)
    raise TemplateError, message
  end

  class TemplateError < StandardError; end

end; end; end; end
