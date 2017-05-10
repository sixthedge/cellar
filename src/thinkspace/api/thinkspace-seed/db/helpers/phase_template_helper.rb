def create_casespace_phase_template(*args)
  options        = args.extract_options!
  phase_template = @seed.new_model(:casespace, :phase_template, options)
  @seed.create_error(phase_template)  unless phase_template.save
  id                   = phase_template.id
  value                = {images: {thumbnail: "https://s3.amazonaws.com/thinkspace_cases/builder/thumbsnails/#{id}.png", preview: "https://s3.amazonaws.com/thinkspace_cases/builder/previews/#{id}.png"}}
  phase_template.value = value
  @seed.create_error(phase_template)  unless phase_template.save
  phase_template
end

def find_casespace_phase_template(*args)
  options = args.extract_options!
  @seed.model_class(:casespace, :phase_template).find_by(options)
end

def casespace_phase_header
  html = <<-TEND
    <row><column><component section='header' title='casespace-phase-header'/></column></row>
  TEND
  html
end

def casespace_phase_submit
  html = <<-TEND
    <row><column><component section='submit' title='casespace-phase-submit'/></column></row>
  TEND
  html
end
