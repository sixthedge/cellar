module Thinkspace
  module Casespace
    module Api
      module Admin
        class PhasesController < ::Totem::Settings.class.thinkspace.authorization_api_controller
          load_and_authorize_resource class: totem_controller_model_class
          totem_action_serializer_options
          before_action :set_common_values
          before_action :set_configuration, only: [:update]

          include Thinkspace::Casespace::Concerns::Phases::Configuration

          def templates
            controller_render(get_templates(@phase_class))
          end

          def clone
            # case_manager_template_id OR phase_id
            # assignment_id to clone into
            template_id   = params[:template_id]
            phase_id      = params[:phase_id]
            assignment_id = params[:assignment_id]
            raise_phase_exception "Cannot clone a phase without a template_id id or phase id." unless (template_id.present? or phase_id.present?)
            raise_phase_exception "Cannot clone a phase without an assignment_id. " unless assignment_id.present?
            assignment = Thinkspace::Casespace::Assignment.find(assignment_id)
            authorize!(:update, assignment)
            if template_id.present?
              template = @template_class.find(template_id)
              raise_phase_exception "Template is not for a phase." unless template.templateable_type == @phase_class.name
              is_template = true
              phase = template.templateable
            else
              is_template = false
              phase = Thinkspace::Casespace::Phase.find(phase_id)
              authorize!(:update, phase)
            end
            new_phase = phase.cyclone(assignment: assignment, is_template: is_template)
            controller_render(new_phase)
          end

          def update
            @builder_abilities      = @phase.get_builder_abilities
            @phase.title            = params_root[:title]            if params_root.has_key?(:title)
            @phase.description      = params_root[:description]      if params_root.has_key?(:description)
            @phase.team_category_id = params_root[:team_category_id] if @builder_abilities[:team_category]
            @phase.default_state    = (params_root[:default_state] || 'unlocked') if @builder_abilities[:default_state]
            update_timetable
            update_phase_team_set if @builder_abilities[:team_set]
            update_phase_configuration # From Phases::Configuration
            totem_serializer_options.phases.update(serializer_options)
            if @phase.save 
              @timetable.save
              controller_render(@phase)
            else
              controller_render_error(@phase)
            end
          end

          def bulk_reset_date
            ids           = params[:ids]
            date_property = params[:property]
            @phases       = Thinkspace::Casespace::Phase.where(id: ids)
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts '***************************************BULKrESETdATE************************************'
            puts @phases
            puts @phases.inspect
            puts ids
            timetables    = Thinkspace::Common::Timetable.where(timeable: @phases, ownerable: nil)
            ActiveRecord::Base.transaction do
              if date_property == 'due_at'
                timetables.update_all(due_at: nil)
              elsif date_property == 'unlock_at'
                timetables.update_all(unlock_at: nil)
                @phases.each do |phase|
                  phase.default_state = 'unlocked'
                  settings = phase.settings.deep_dup
                  settings[:actions][:submit].delete(:unlock) if settings.has_key?(:actions) and settings[:actions].has_key?(:submit)
                  phase.settings = settings
                  phase.save
                end
              end
            end
            controller_render(@phases)
          end

          def destroy
            assignment = @phase.thinkspace_casespace_assignment
            authorize! :update, assignment
            controller_destroy_record(@phase)
          end

          def componentables
            authorize!(:update, @phase)
            components           = @phase.thinkspace_casespace_phase_components.where.not(componentable_type: controller_model_class_name)
            phase_componentables = components.map {|component| component.componentable}
            controller_render_included(phase_componentables)
          end

          # ### States
          def archive
            @phase.archive!
            controller_render(@phase)
          end

          def activate
            @phase.activate!
            controller_render(@phase)
          end

          def inactivate
            @phase.inactivate!
            controller_render(@phase)
          end

          # ### Ownerable data
          def delete_ownerable_data
            authorize!(:update, @phase)
            ownerable_type = params[:ownerable_type]
            ownerable_id   = params[:ownerable_id]
            raise_access_denied_exception "Cannot delete ownerable data without an ownerable_type", :delete_ownerable_data, @phase unless ownerable_type.present?
            raise_access_denied_exception "Cannot delete ownerable data without an ownerable_id", :delete_ownerable_data, @phase unless ownerable_id.present?
            klass = ownerable_type.classify.safe_constantize
            raise_access_denied_exception "Cannot delete ownerable data without a valid klass [#{ownerable_type}]", :delete_ownerable_data, @phase unless klass.present?
            ownerable = klass.find_by(id: ownerable_id)
            raise_access_denied_exception "Cannot delete ownerable data without a valid ownerable_id [#{ownerable_id}]", :delete_ownerable_data, @phase unless ownerable.present?
            @phase.delete_ownerable_data(ownerable)
            controller_render(@phase)
          end

          private

          def get_templates(klass)
            @template_class.where(templateable_type: klass.name)
          end

          def set_common_values
            @space_class      = Thinkspace::Common::Space
            @user_class       = Thinkspace::Common::User
            @config_class     = Thinkspace::Common::Configuration
            @assignment_class = Thinkspace::Casespace::Assignment
            @phase_class      = Thinkspace::Casespace::Phase
            @template_class   = Thinkspace::Builder::Template
            @team_class       = Thinkspace::Team::Team
          end

          def set_configuration
            @params_configuration = params[:configuration]
            @configuration        = @phase.get_configuration
            raise_phase_exception "Phase  [id: #{@phase.id}] does not have a configuration."  if @configuration.blank? 
          end

          def update_phase_team_set
            team_set_id           = params_root[:team_set_id]
            if team_set_id.present?
              team_set              = Thinkspace::Team::TeamSet.find_by(id: team_set_id)
              raise_phase_exception "Team set is not a valid reference [#{team_set_id}]" unless team_set.present?
              raise_phase_exception "Team set does not belong to phase's space."         unless team_set.get_space == @phase.get_space
              @phase.assign_team_set(team_set)
            else
              @phase.unassign_team_set
            end
          end

          def update_timetable
            @timetable = Thinkspace::Common::Timetable.find_or_create_by(timeable: @phase, ownerable: nil)
            @timetable.unlock_at = params_root[:unlock_at] if params_root.has_key?(:unlock_at)
            @timetable.due_at    = params_root[:due_at]
          end

          # ### Error helpers
          def raise_phase_exception(message='')
            raise PhaseException.new message
          end

          class PhaseException < StandardError; end;

        end
      end
    end
  end
end
