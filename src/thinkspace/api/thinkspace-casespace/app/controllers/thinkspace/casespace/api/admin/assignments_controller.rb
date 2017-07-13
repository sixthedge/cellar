module Thinkspace
  module Casespace
    module Api
      module Admin
        class AssignmentsController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :set_common_values
          before_action :set_common_assignment_values, only: [:create, :update]

          def templates
            controller_render(get_templates(@assignment_class))
          end

          def clone
            space_id = params[:space_id]
            raise_assignment_exception "Cannot clone an assignment without a space id." if space_id.blank?
            space = Thinkspace::Common::Space.find_by(id: space_id)
            raise_assignment_exception "Space id #{space_id} not found." if space.blank?
            authorize!(:update, space)
            clone_assignment = @assignment.cyclone(space: space)
            controller_render(clone_assignment)
          end

          def load
            controller_render(@assignment)
          end

          def create
            assignment_type_id = params_association_id(:assignment_type_id)
            assignment_type    = Thinkspace::Casespace::AssignmentType.find(assignment_type_id)
            creator_class      = assignment_type.get_creator_class
            creator            = creator_class.new(params)
            @assignment        = creator.generate
            controller_render(@assignment)
          end

          def update
            # TODO: Transaction wrap?
            template_id = params_root[:template_id]

            case
            when template_id.present?
              template = @template_class.find_by(id: template_id)
              raise_access_denied_exception "Template ID is invalid [#{template_id}]." unless template.present?
              templateable = template.templateable
              raise_access_denied_exception "Template does not have a valid templateable." unless templateable.present? && templateable.class == @assignment_class
              phases = templateable.thinkspace_casespace_phases.order(:position)
              @assignment.thinkspace_casespace_phases.map(&:archive!)

              dictionary = Hash.new
              phases.each do |p|
                cloned_phase = p.cyclone(assignment: @assignment, dictionary: dictionary)
              end

              controller_render(@assignment)
            else
              if @assignment.neutral? || @assignment.inactive?
                @assignment.save(validate: false) # ignore validations if neutral or inactive
                controller_render(@assignment)
              else
                controller_save_record(@assignment)
              end
            end

          end

          def explode
            @assignment.explode
            controller_render_no_content
          end

          def delete
            raise_access_denied_exception "Cannot delete a peer assessment assignment.", :clone, @assignment  if @assignment.peer_assessment?
            @assignment.to_deleted # set state to deleted
            raise_assignment_exception "Assignment [id: #{@assignment.id}] could not be saved as deleted."  unless @assignment.save
            controller_render_no_content
          end

          def phase_order
            phase_order = params[:phase_order]
            raise_assignment_exception "Assignment [id: #{@assignment.id}] phase order is not an array."  unless phase_order.kind_of?(Array)
            phases = []
            @assignment.transaction do
              phase_order.each do |hash|
                phase_id = hash[:phase_id]
                position = hash[:position]
                raise_assignment_exception "Assignment [id: #{@assignment.id}] phase order phase id is blank."  if phase_id.blank?
                raise_assignment_exception "Assignment [id: #{@assignment.id}] phase order phase position [#{position.inspect}] is invalid."  unless position.kind_of?(Fixnum)
                phase          = get_and_authorize_phase(phase_id)
                phase.position = position
                raise_assignment_exception "Unable to save phase [id: #{phase.id}]."  unless phase.save
                phases.push phase
              end
            end
            controller_render(phases)
          end

          def phase_componentables
            componentable_type = params[:componentable_type]
            raise_assignment_exception('Cannot find phase componentables without a valid componentable_type.') unless componentable_type.present?
            componentable_class = componentable_type.classify.safe_constantize
            raise_assignment_exception("componentable_type [#{componentable_type}] is invalid, no class found.") unless componentable_class.present?
            phase_ids         = @assignment.thinkspace_casespace_phases.pluck(:id)
            componentable_ids = @phase_component_class.accessible_by(current_ability).where(phase_id: phase_ids, componentable_type: componentable_class).pluck(:componentable_id)
            componentables    = componentable_class.accessible_by(current_ability).where(id: componentable_ids)
            controller_render(componentables)
          end

          # ### States
          def inactivate
            @assignment.inactivate!
            controller_render(@assignment)
          end

          def activate
            @assignment.activate
            phase_ids       = @assignment.thinkspace_casespace_phases.pluck(:id)
            componentables  = @phase_component_class.accessible_by(current_ability).where(phase_id: phase_ids).where.not(componentable_type: @phase_class.name).map(&:componentable)
            componentables.each do |componentable|
              componentable.activate! if (componentable.respond_to?(:may_activate?) && componentable.may_activate?)
            end
            controller_save_record(@assignment)
          end

          def archive
            @assignment.archive
            controller_save_record(@assignment)
          end

          private

          def get_templates(klass)
            @template_class.where(templateable_type: klass.name)
          end

          def set_common_values
            @space_class           = Thinkspace::Common::Space
            @user_class            = Thinkspace::Common::User
            @config_class          = Thinkspace::Common::Configuration
            @assignment_class      = Thinkspace::Casespace::Assignment
            @phase_class           = Thinkspace::Casespace::Phase
            @phase_component_class = Thinkspace::Casespace::PhaseComponent
            @template_class        = Thinkspace::Builder::Template
            @team_class            = Thinkspace::Team::Team
          end

          def get_and_authorize_phase(phase_id = params[:phase_id])
            raise_assignment_exception "Phase id is blank."  if phase_id.blank?
            phase = @phase_class.accessible_by(current_ability, :update).find_by(id: phase_id)
            raise_assignment_exception("Unauthorized to access phase [id: #{phase_id.inspect}]", :update, @phase_class)  if phase.blank?
            phase
          end

          # Bundle type creation helpers
          def set_common_assignment_values
            update_timetable
            @assignment.title        = params_root[:title]        if params_root_has?(:title)
            @assignment.description  = params_root[:description]  if params_root_has?(:description)
            @assignment.name         = params_root[:name]         if params_root_has?(:name)
            @assignment.instructions = params_root[:instructions] if params_root_has?(:instructions)
            @assignment.bundle_type  = params_root[:bundle_type]  if params_root_has?(:bundle_type)
            @assignment.state        = params_root[:state]        if params_root_has?(:state)
            @assignment.settings     = params_root[:settings]     if params_root_has?(:settings)
          end

          def update_timetable
            due_at               = params_root[:due_at] if params_root_has?(:due_at)
            release_at           = params_root[:release_at] if params_root_has?(:release_at)
            timetable            = @assignment.get_or_set_timetable_for_self
            if due_at.present? || release_at.present?
              timetable.due_at     = due_at if due_at.present?
              timetable.release_at = release_at if release_at.present?
              timetable.save
            end
          end
          
          def included_options
            params_root[:included_options]
          end

          def params_root_has?(key)
            params_root.has_key?(key)
          end

          def params_configuration_has?(key)
            return false unless params.has_key?(:configuration)
            params_configuration = params[:configuration]
            params_configuration.has_key?(key)
          end

          def get_params_configuration; params[:configuration]; end

          def raise_assignment_exception(message='')
            raise AssignmentException.new message
          end

          class AssignmentException < StandardError; end;

        end
      end
    end
  end
end
