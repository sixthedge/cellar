module Thinkspace; module Casespace; module Creators; class Base

    attr_accessor :params
    attr_accessor :assignment

    ### Class definitions

    def assignment_class; Thinkspace::Casespace::Assignment; end


    ### Assignment helpers

    def create_assignment_from_params
      assignment_type_id = params_association_path_id('thinkspace/casespace/assignment_type_id')
      space_id           = params_association_path_id('thinkspace/common/space_id')

      model = assignment_class.new(assignment_type_id: assignment_type_id, space_id: space_id, state: :inactive)
      model.save(validate: false) # skip validations
      model
    end


    ### Phase helpers

    def create_phase(options={})
      phase                   = Thinkspace::Casespace::Phase.new
      phase.assignment_id     = options[:assignment_id]
      phase.phase_template_id = options[:phase_template_id]
      phase.team_category_id  = options[:team_category_id]
      phase.title             = options[:title] || 'Peer Assessment Phase'
      phase.description       = options[:description] || 'Peer assessment description.'
      phase.state             = options[:state] || :inactive
      phase.default_state     = options[:default_state] || 'unlocked'
      phase.position          = options[:position] || 1
      phase.save
      phase
    end

    def create_header_component(phase); create_phase_component(phase, phase, 'casespace-phase-header', 'header'); end
    def create_submit_component(phase); create_phase_component(phase, phase, 'casespace-phase-submit', 'submit'); end

    def create_phase_component(phase, componentable, component_title, section)
      component = Thinkspace::Common::Component.find_by(title: component_title)
      raise "Component with title #{component_title.inspect} not found." if component.blank?
      phase_component = phase.thinkspace_casespace_phase_components.create(
        componentable: componentable,
        component_id:  component.id,
        section:       section
      )
      phase_component
    end



    ### Params Helpers


    def params_data; params[:data]; end

    # Controller's root key
    def params_root
      data = params_data
      raise "Missing params[:data][:attributes] controller params for [#{self.class.name}]"  unless data.has_key?(:attributes)
      data[:attributes]
    end

    def params_association_path_id(assoc_key)
      assoc_key     = assoc_key.to_s.sub(/_id$/,'')
      data          = params_data
      relationships = data[:relationships]
      raise "Missing params[:data][:relationships] controller params for [#{self.class.name}]"  if relationships.blank?
      raise "Missing params[:data][:relationships][#{assoc_key}] controller params for [#{self.class.name}]"  unless relationships.has_key?(assoc_key)
      assoc_data = relationships[assoc_key]
      assoc_data[:data][:id]
    end

end; end; end; end