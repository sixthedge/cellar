require 'nokogiri'

#########################################################################################
# ###
# ### Phase Templates.
# ###

def casespace_seed_config_add_phase_templates(config)
  templates = [config[:phase_templates]].flatten.compact
  return if templates.blank?
  seed_config_message('++Adding seed config phase templates.', config)
  templates.each do |hash|
    template = hash[:template]
    seed_config_error "Phase template does not have a template value [template: #{hash.inspect}].", config  if template.blank?
    template = template.gsub '#{casespace_phase_header}', casespace_phase_header
    template = template.gsub '#{casespace_phase_submit}', casespace_phase_submit
    create_casespace_phase_template(hash.merge(template: template))
  end
end

# Check if any seed phase components should be built after other section components in the same phase template.
# For example, if a section's 'componentable' depends on another section's 'componentable' but is
# defined before the dependent section in the phase_template.
def get_ordered_phase_template_section_hash(phase_template)
  do_last        = ['diagnostic-path-viewer']  # hard coded list of known components to build last
  component_hash = ActiveSupport::OrderedHash.new
  last_array     = Array.new
  template_hash  = casespace_parse_phase_template(phase_template)
  template_hash.each do |section, attrs|
    title = attrs['title']
    @seed.error "Phase template name #{phase_template.name.inspect} does not have a title."  if title.blank?
    match_do_last = do_last.select {|t| title.start_with?(t)}
    match_do_last.blank? ? component_hash[section] = attrs : last_array.push([section, attrs])
  end
  last_array.each do |section_array|
    component_hash[section_array.first] = section_array.last
  end
  component_hash
end

def casespace_parse_phase_template(template)
  hash       = Hash.new
  html       = Nokogiri::HTML.fragment(template.template)
  components = html.css('component')
  check_casespace_phase_template(template, components)
  components.each do |component|
    comp    = Hash.from_xml(component.to_s)['component'] || Hash.new
    section = comp.delete('section') || comp['title']  # totem-template-manager will default the section to the title
    hash[section] = comp
  end
  hash
end

def check_casespace_phase_template(template, components)
  references = Array.new
  sections   = Array.new
  components.each do |component|
    section = component.attributes['section'] || component.attributes['title'] # totem-template-manager will default the section to the title
    @seed.error "Phase template name #{template.name.inspect} component tag is missing a section attribute [#{component.to_s}]."  if section.blank?
    section = section.to_s
    @seed.error "Phase template name #{template.name.inspect} has a duplicate section value #{section.inspect} [#{component.to_s}]."  if sections.include?(section)
    sections.push(section)
    attributes = component.attributes
    attributes.each do |key, value|
      next if key == 'title'
      next if key == 'section'
      next if key.start_with?('data-')
      if value.present?
        value = value.to_s
        next  if value == 'true' || value == 'false'  # if a boolean, then is not a reference to another section
        values      = value.split(' ').select {|v| v.present?}
        references += values.map {|v| v.strip}
      end
    end
  end
  references  = [references].flatten.compact.uniq
  not_defined = references - sections
  @seed.error "Phase template name #{template.name.inspect} has undefined references #{not_defined}."  if not_defined.present?
end

