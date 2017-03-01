def html_sample_content_html_only(options={})
  id, description = html_sample_content_id_and_description_from_options(options)
  content     = <<-TEND
    #{html_sample_content_title(id, description)}
    #{html_sample_content_text_1}
    #{html_sample_content_text_2}
  TEND
  html_format_sample_content(content)
end

def html_sample_content_html_input_a(options={})
  id, description = html_sample_content_id_and_description_from_options(options, :a)
  content = <<-TEND
    #{html_sample_content_title(id, description)}
    #{html_sample_content_checkbox(id, 1)}
    #{html_sample_content_textfield(id, 1)}
    #{html_sample_content_textarea(id, 1)}
  TEND
  html_format_sample_content(content)
end

def html_sample_content_html_input_b(options={})
  id, description = html_sample_content_id_and_description_from_options(options, :b)
  content = <<-TEND
    #{html_sample_content_title(id, description)}
    #{html_sample_content_checkbox(id, 1)}
    #{html_sample_content_checkbox(id, 2)}
    #{html_sample_content_textfield(id, 1)}
    #{html_sample_content_textfield(id, 2)}
    #{html_sample_content_textarea(id, 1)}
  TEND
  html_format_sample_content(content)
end

def html_sample_content_html_carry_forward_assignment_all(phase, options)
  id, description = html_sample_content_id_and_description_from_options(options, :a)
  content = <<-TEND
    #{html_sample_content_title(id, description)}
    #{html_sample_content_textfield(id, 1)}
    #{html_sample_content_textfield(id, 2)}
  TEND
  assignment = @seed.get_association(phase, :casespace, :assignment)
  phases     = @seed.get_association(assignment, :casespace, :phases)
  elements   = html_sample_content_html_get_input_elements_for_phases(phases)
  content   += html_sample_content_html_get_carry_forward_tags(elements)
  html_format_sample_content(content)
end


def html_sample_content_html_get_input_elements_for_phases(phases)
  comp_class     = @seed.model_class(:casespace, :phase_component)
  content_class  = @seed.model_class(:html, :content)
  element_class  = @seed.model_class(:input_element, :element)
  components     = comp_class.where(phase_id: phases.map(&:id), componentable_type: content_class.name)
  componentables = components.map(&:componentable)
  element_class.where(componentable: componentables).order(:id)
end

def html_sample_content_html_get_carry_forward_tags(elements)
  content_left  = '<div class="small-6 columns">'
  content_right = '<div class="small-6 columns">'
  elements.each_with_index do |element, index|
    name = element.name
    text = "<h5>Carry forward: #{name} [eid:#{element.id}]</h5>"
    tag  = index.even? ? "<thinkspace type='carry_forward' name='#{name}' title='table'>" : "<thinkspace type='carry_forward' name='#{name}'>"
    tag += '</thinkspace>'
    row  = '<div class="row"><div class="small-12 columns">'
    row += text
    row += tag
    row += '</div></div>'
    index.even? ? content_left += row : content_right += row
  end
  '<div class="row">' + content_left + '</div>' + content_right + '</div>' + '</div>'
end