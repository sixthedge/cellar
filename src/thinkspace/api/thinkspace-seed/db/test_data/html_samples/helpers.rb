def html_sample_content_id_and_description_from_options(options, suffix=nil)
  id          = options[:id] || ''
  id          = id.to_s.gsub('.', '_').gsub('-', '_')
  id         += "_#{suffix}"  if suffix.present?
  description = options[:description] || 'Sample HTML Content.'
  [id, description]
end

def html_sample_content_title(id, description)
  content = <<-TEND
    <h3>#{id} #{description}</h3>
  TEND
  content
end

def html_sample_content_checkbox(id, id_number=1)
  content = <<-TEND
    <div class="row">
      <div class="small-1 columns"><input name="#{id}_checkbox_#{id_number}" type="checkbox" /></div>
      <div class="small-11 columns"><p>This is checkbox #{id} #{id_number}</p></div>
    </div>
  TEND
  content
end

def html_sample_content_textfield(id, id_number=1)
  content = <<-TEND
    <div class="row">
      <div class="small-12 columns">
        <p>This is input text field #{id} #{id_number}</p>
        <input name="#{id}_textfield_#{id_number}" type="text" />
      </div>
    </div>
  TEND
  content
end

def html_sample_content_textarea(id, id_number=1)
  content = <<-TEND
    <div class="row">
      <div class="small-12 columns">
        <p>This is textarea #{id} #{id_number}</p>
        <textarea name="#{id}_textarea_#{id_number}"></textarea>
      </div>
    </div>
  TEND
  content
end

def html_sample_content_text_1
  content = <<-TEND
    <div class="row">
      <div class="small-12 columns">
        <p>
          ThinkSpace is a growing constellation of innovative learning applications each supported
          by a passionate community of users.  Join us to provide transformative learning experiences
          for your own students in an exciting, collaborative, online environment.
        </p>
      </div>
    </div>
  TEND
  content
end

def html_sample_content_text_2
  content = <<-TEND
    <div class="row">
      <div class="small-12 columns">
        <p>
          Our hub has a variety of effective learning applications with ready-to-use cases that can be
          used to enhance your teaching or simply embed the tools from the app into your own custom case.
        </p>
      </div>
    </div>
  TEND
  content
end
