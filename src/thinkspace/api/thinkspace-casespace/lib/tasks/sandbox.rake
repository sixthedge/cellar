namespace :thinkspace do
  namespace :sandbox do
    namespace :add do

      task :simulations, [] => [:environment] do |t, args|
        user_id = ENV['USER_ID']
        raise_error 'Cannot add a simulation sandbox without a user_id.' unless user_id.present?
        user = user_class.find_by(id: user_id)
        raise_error "Cannot add a simulation sandbox without a valid user for [#{user_id}]" unless user.present?

        title = ENV['SPACE_TITLE'] || 'Simulations Sandbox'
        space_class.transaction do
          @phase_position = 0
          space = casespace_space(title)
          add_mountain_simulation(space)
          add_radiation_simulation(space)
          add_budget_simulation(space)
          space.add_user_as_owner(user)
        end
      end

      task :custom, [] => [:environment] do |t, args|
        assignment_ids = ENV['ASSIGNMENT_IDS']
        phase_ids      = ENV['PHASE_IDS']
        emails         = ENV['EMAILS']
        phase_ids      = config_comma_string_to_array(phase_ids)
        assignment_ids = config_comma_string_to_array(assignment_ids)
        emails         = config_comma_string_to_array(emails)

        raise_error "Cannot create a custom sandbox without phase_ids or assignment_ids." unless assignment_ids.present? or phase_ids.present?
        emails.present? ? title = "Sandbox for #{emails.join(' - ')}" : title = "Custom ThinkSpace Sandbox [#{Time.now}]"
        space_class.transaction do
          space = casespace_space(title)

          assignment_ids.each do |id|
            assignment = assignment_class.find_by(id: id)
            unless assignment.present?
              print_message "Skipping assignment id [#{id}] as it does not exist for the sandbox creation." 
              next
            end
            print_message "      + cloning assignment: [#{assignment.id}] into space [#{space.id}]" if verbose?
            assignment.cyclone(space: space)
          end

          if phase_ids.present?
            assignment = casespace_assignment(space, "À la carte ThinkSpace Sandbox")
            phase_ids.each do |id|
              phase = phase_class.find_by(id)
              unless phase.present?
                print_message "Skipping phase id [#{id}] as it does not exist for the sandbox creation." 
                next
              end
              print_message "      + cloning phase: [#{phase.id}] into assignment [#{assignment.id}]" if verbose?
              phase.cyclone(assignment: assignment)
            end
          end

          if emails.present?
            emails.each do |email|
              user = user_class.find_by(email: email)
              unless user.present?
                print_message "Skipping adding of user [#{email}] as they do not exist."
                next
              end
              print_message "      + adding user: [#{user.id}] as owner on space [#{space.id}]" if verbose?
              space.add_user_as_owner(user)
            end
          end
        end 

      end

      # Classes
      def user_class; Thinkspace::Common::User; end
      def space_class; Thinkspace::Common::Space; end
      def phase_template_class; Thinkspace::Casespace::PhaseTemplate; end
      def assignment_class; Thinkspace::Casespace::Assignment; end
      def phase_class; Thinkspace::Casespace::Phase; end
      def common_component_class; Thinkspace::Common::Component; end
      def space_type_class; Thinkspace::Common::SpaceType; end
      def simulation_class; Thinkspace::Simulation::Simulation; end
      def html_content_class; Thinkspace::Html::Content; end

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

      # Simulation
      def add_mountain_simulation(space, options={})
        assignment     = assignment_class.create(title: 'Mountain Simulation', space_id: space.id)
        phase_template = phase_template_class.find_by(name: 'one_column_html_and_simulation_submit')
        position       = options[:position] || 1
        phase          = phase_class.create(title: 'Simulation', assignment_id: assignment.id, phase_template_id: phase_template.id, default_state: 'unlocked', position: position, active: true)
        componentable  = simulation_class.create(title: 'Mountain', path: 'mountain', authable: phase)
        create_header_component(phase)
        create_submit_component(phase)
        create_html_component(phase)
        create_phase_component(phase, componentable, 'simulation', 'simulation')
      end

      def add_radiation_simulation(space, options={})
        assignment     = assignment_class.create(title: 'Radiation Simulation', space_id: space.id)
        phase_template = phase_template_class.find_by(name: 'one_column_html_and_simulation_submit')
        position       = options[:position] || 1
        phase          = phase_class.create(title: 'Simulation', assignment_id: assignment.id, phase_template_id: phase_template.id, default_state: 'unlocked', position: position, active: true)
        componentable  = simulation_class.create(title: 'Radiation', path: 'radiation', authable: phase)
        create_header_component(phase)
        create_submit_component(phase)
        create_html_component(phase)
        create_phase_component(phase, componentable, 'simulation', 'simulation')
      end

      def add_budget_simulation(space, options={})
        assignment     = assignment_class.create(title: 'Budget Simulation', space_id: space.id)
        phase_template = phase_template_class.find_by(name: 'one_column_html_and_simulation_submit')
        position       = options[:position] || 1
        phase          = phase_class.create(title: 'Simulation', assignment_id: assignment.id, phase_template_id: phase_template.id, default_state: 'unlocked', position: position, active: true)
        componentable  = simulation_class.create(title: 'Budget', path: 'budget', authable: phase)
        create_header_component(phase)
        create_submit_component(phase)
        create_html_component(phase)
        create_phase_component(phase, componentable, 'simulation', 'simulation')
      end

      # HTML
      def create_html_component(phase, options={})
        componentable   = html_content_class.create(authable: phase, html_content: '')
        component_title = options[:select_text].present? ? 'html-select-text' : 'html'
        create_phase_component(phase, componentable, component_title, 'html')
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
end
