#{staging_html_radio(id)}
def staging_html_content_one_each_with_paragraph(phase, options={})
  id = "phase_#{phase.id}"
  content = <<-TEND
    #{staging_html_content_text}
    #{staging_html_checkbox(id)}
    #{staging_html_radio(id)}
    #{staging_html_input(id)}
    #{staging_html_textarea(id)}
  TEND
  html_format_sample_content(content)
end

def staging_html_input(id, n=1)
  name    = "textfield_#{id}_n_#{n}"
  content = "<input name=\"#{name}\" type=\"text\"></input>"
  html_row_wrap content, "text [#{name}]"
end

def staging_html_checkbox(id, n=1)
  name    = "checkbox_#{id}_n_#{n}"
  content = "<input name=\"#{name}\" type=\"checkbox\"></input>"
  html_row_wrap content, "checkbox [#{name}]"
end

def staging_html_radio(id, n=1, vals=4)
  name = "radio_#{id}_n_#{n}"
  if vals.is_a?(Array)
    values = vals
  else
    values = Array.new
    vals.times {|i| values.push("radio button #{i+1}")}
  end
  content = ''
  values.each_with_index do |value, index|
    content += "<input name=\"#{name}\" type=\"radio\" value=\"#{value}\">#{value}</input>"
    content += '</br>' if (index + 1) < values.length
  end
  content = '<div style="margin-bottom: 1em;">' + content + '</div>'
  html_row_wrap(content, "radio [#{name}]")
end

def staging_html_textarea(id, n=1)
  name    = "textarea_#{id}_n_#{n}"
  content = "<textarea name=\"#{name}\"></textarea>"
  html_row_wrap content, "textarea [#{name}]"
end

def html_row_wrap(html, label=nil)
  content = '<div class="ts-grid_row"><div class="ts-grid_columns small-12">'
  content += staging_html_label(label)  if label.present?
  content += html
  content += '</div></div>'
  content
end

def staging_html_label(label); "<h6>#{label || ''}</h6>"; end

def staging_html_content_text
  content = <<-TEND
    <p>
      ThinkSpace is a growing constellation of innovative learning applications each supported
      by a passionate community of users.  Join us to provide transformative learning experiences
      for your own students in an exciting, collaborative, online environment.
    </p>
    <p>
      Our hub has a variety of effective learning applications with ready-to-use cases that can be
      used to enhance your teaching or simply embed the tools from the app into your own custom case.
    </p>
  TEND
  html_row_wrap(content)
end

def staging_html_carry_forward(phase, options={})
  title = (options[:config] || Hash.new)[:carry_forward]
  return if title.blank?
  from_phase = find_casespace_phase(title: title)
  elements   = staging_html_content_input_elements_for_phases([from_phase])
  content    = staging_html_carry_forward_tags(elements)
  html_format_sample_content(content)
end

def staging_html_carry_forward_tags(elements)
  content  = '<table style="table-layout: auto; width: auto;">'
  content += '<thead><th>Element Type</th><th>Carry Forward Tag</th><th>Carry Forward Value</th></thead><tbody>'
  elements.each do |element|
    name     = element.name
    type     = element.element_type
    tag      = "<thinkspace type=\"carry_forward\" name=\"#{name}\"></thinkspace>"
    etag     = staging_escape_html(tag)
    content += "<tr><td>#{type}</td><td style=\"padding-right: 2em;\">#{etag}</td><td style=\"font-weight: 500;\">#{tag}</td></tr>"
  end
  content += '</tbody></table>'
  html_row_wrap(content)
end

def staging_html_content_input_elements_for_phases(phases)
  content_class  = @seed.model_class(:html, :content)
  element_class  = @seed.model_class(:input_element, :element)
  components     = @seed.model_class(:casespace, :phase_component).where(phase_id: phases.map(&:id), componentable_type: content_class.name)
  componentables = components.map(&:componentable)
  element_class.where(componentable: componentables).order(:id)
end

def staging_escape_html(html); ERB::Util.html_escape(html); end
