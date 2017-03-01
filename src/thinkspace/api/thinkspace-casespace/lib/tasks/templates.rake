namespace :thinkspace do
  namespace :templates do
    task :add, [] => [:environment] do |t, args|





    end

    def add_phase_templates
      add_one_column_html
      add_two_column_html
    end

    def add_case_templates

    end

    # Classes
    def user_class;             Thinkspace::Common::User; end
    def space_class;            Thinkspace::Common::Space; end
    def phase_template_class;   Thinkspace::Casespace::PhaseTemplate; end
    def assignment_class;       Thinkspace::Casespace::Assignment; end
    def phase_class;            Thinkspace::Casespace::Phase; end
    def common_component_class; Thinkspace::Common::Component; end
    def space_type_class;       Thinkspace::Common::SpaceType; end
    def simulation_class;       Thinkspace::Simulation::Simulation; end
    def html_content_class;     Thinkspace::Html::Content; end
    def artifact_bucket_class;  Thinkspace::Artifact::Bucket; end
    def observation_list_class; Thinkspace::ObservationList::List; end

    # Phase Templates
    def add_phase_template(type, options={})
      phase  = phase_class.create(title: 'Temporary Title')
      method = "add_#{type}"
      self.send(method, phase, options) if self.respond_to?(method)
    end

    def add_one_column_html(phase, options={})
      phase_template = phase_template_class.find_by(name: 'one_column_html_submit')
      create_header_and_submit_components(phase)
      create_html_component(phase, 'html')
    end

    def add_two_column_html(phase, options={})
      phase_template = phase_template_class.find_by(name: 'two_column_html_html_submit')
      create_header_and_submit_components(phase)
      create_html_component(phase, 'html-1')
      create_html_component(phase, 'html-2')
    end

    def add_artifact(phase, options={})
      phase_template = phase_template_class.find_by(name: 'one_column_artifact_submit')
      create_header_and_submit_components(phase)
      create_artifact_component(phase)
    end

    def add_html_with_artifact(phase, options={})
      phase_template = phase_template_class.find_by(name: 'one_column_html_artifact_submit')
      create_header_and_submit_components(phase)
      create_html_component(phase, 'html')
      create_artifact_component(phase)
    end

    def add_html_with_observation_list(phase, options={})
      phase_template = phase_template_class.find_by(name: 'two_column_html_observation_list_submit')
      create_header_and_submit_components(phase)
      create_html_component(phase, 'html', select_text: true)
      create_observation_list_component(phase, 'obs-list')
    end

    def add_lab(phase, options={})
      phase_template = phase_template_class.find_by(name: 'two_column_lab_observation_list_submit')
      create_header_and_submit_components(phase)
    end

    def add_path(phase, options={})
      phase_template = phase_template_class.find_by(name: 'one_column_indented_list')
      create_header_and_submit_components(phase)
    end

    def add_expert_path(phase, options={})
      phase_template = phase_template_class.find_by(name: 'one_column_indented_list')
      create_header_and_submit_components(phase)
    end

    def add_peer_evaluation(phase, options={})
      phase_template = phase_template_class.find_by(name: 'peer_assessment/assessment')
      create_header_and_submit_components(phase)
    end

    def add_peer_evaluation_overview(phase, options={})
      phase_template = phase_template_class.find_by(name: 'peer_assessment/overview')
      create_header_and_submit_components(phase)
    end

    # Casespace helpers
    def casespace_bundle_type; 'casespace'; end
    def casespace_space_type; space_type_class.find_by(title: 'Casespace'); end
    def casespace_space(title)
      space = space_class.create(title: title)
      space.thinkspace_common_space_types << casespace_space_type
      space
    end
    def casespace_assignment(space, title)
      assignment_class.create(title: title, space_id: space.id, bundle_type: casespace_bundle_type, release_at: Time.now, due_at: Time.now + 6.months)
    end

    # Phase Component helpers
    def create_header_and_submit_components(phase)
      create_header_component(phase)
      create_submit_component(phase)
    end
    def create_header_component(phase); create_phase_component(phase, phase, 'casespace-phase-header', 'header'); end
    def create_submit_component(phase); create_phase_component(phase, phase, 'casespace-phase-submit', 'submit'); end
    def create_phase_component(phase, componentable, component_title, section)
      component = common_component_class.find_by(title: component_title)
      error "Component with title #{component_title.inspect} not found." if component.blank?
      phase_component = phase.thinkspace_casespace_phase_components.create(
        componentable: componentable,
        component_id:  component.id,
        section:       section
      )
      print_message "      + component: #{component_title.inspect} section: #{section.inspect} componentable: #{componentable.class.name}.#{componentable.id}"  if verbose?
      phase_component
    end

    # HTML
    def create_html_component(phase, section='html', options={})
      componentable   = html_content_class.create(authable: phase, html_content: '')
      component_title = options[:select_text].present? ? 'html-select-text' : 'html'
      create_phase_component(phase, componentable, component_title, section)
    end

    # Artifact
    def create_artifact_component(phase, section='artifact', options={})
      componentable = artifact_bucket_class.create(authable: phase)
      create_phase_component(phase, componentable, 'artifact-bucket', section)
    end

    # Observation List
    def create_observation_list_component(phase, section='obs-list', options={})
      componentable = observation_list_class.create(authable: phase)
      # TODO: Options include category?  Other settings!
      create_phase_component(phase, componentable, 'observation-list', section)
    end

    # Generic helpers
    def verbose?; true; end
    def raise_error(message)
      raise "[thinkspace:sandbox:add] - #{message}."
    end

    def print_message(message='')
      puts '[thinkspace:sandbox:add] ' + message
    end

    def config_comma_string_to_array(string)
      return [] unless string.present?
      string.split(',').map { |i| i.to_s.strip }
    end


  end
end