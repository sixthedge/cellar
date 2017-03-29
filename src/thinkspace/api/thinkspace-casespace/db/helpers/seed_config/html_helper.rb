#########################################################################################
# ###
# ### Html Phase Componentable.
# ###
def create_casespace_phase_componentable_html(phase, section, common_component, config)
  method      = config[:method]
  sample      = config[:sample]
  description = common_component.title
  id          = section
  if method.present?
    @seed.error "Missing html content method #{method.inspect} for phase #{path_phase.title.inspect} section #{section.inspect}."  unless Object.respond_to?(method, true)
    html_content = self.send(method, phase, id: id, description: description, config: config)
  else
    alpha = ''
    if sample.blank?
      alpha        = get_casespace_alpha(phase.position-1) || 'a'
      sample       = 'default_'
    end
    html_content = html_get_sample_content(sample + alpha.downcase, id: id, description: description)
    if html_content.blank?
      html_content = html_get_sample_content(sample + 'a', id: id, description: description)
    end
  end
  content       = create_html_content authable: phase, html_content: html_content
  preprocessors = common_component.preprocessors
  if preprocessors.present?
    create_input_elements(content, :html_content)
  end
  content
end

def create_html_content(*args)
  options = args.extract_options!
  content = @seed.new_model(:html, :content, options)
  @seed.create_error(content)  unless content.save
  content
end

def html_get_sample_content(sample_id, options={})
  sample_method = "html_sample_content_#{sample_id.to_s}".to_sym
  return nil  unless Object.respond_to?(sample_method, true)
  self.send(sample_method, options)
end

def html_format_sample_content(content)
  return '' if content.blank?
  content.gsub(/\s\s+/, ' ').gsub("\n", ' ')
end