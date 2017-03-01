def html_sample_content_default_a(options={})
  id, description = html_sample_content_id_and_description_from_options(options, :a)
  content = <<-TEND
    #{html_sample_content_title(id, description)}
    #{html_sample_content_checkbox(id, 1)}
    #{html_sample_content_textfield(id, 1)}
  TEND
  html_format_sample_content(content)
end

def html_sample_content_default_b(options={})
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

def html_sample_content_default_c(options={})
  id, description = html_sample_content_id_and_description_from_options(options, :c)
  content     = <<-TEND
    #{html_sample_content_title(id, description)}
    #{html_sample_content_checkbox(id, 1)}
    #{html_sample_content_checkbox(id, 2)}
    #{html_sample_content_textfield(id, 1)}
    #{html_sample_content_textfield(id, 2)}
    #{html_sample_content_textarea(id, 1)}
    #{html_sample_content_textarea(id, 2)}
  TEND
  html_format_sample_content(content)
end

def html_sample_content_default_d(options={})
  id, description = html_sample_content_id_and_description_from_options(options, :d)
  content     = <<-TEND
    #{html_sample_content_title(id, description)}
    <h4>No input fields</h4>
  TEND
  html_format_sample_content(content)
end

