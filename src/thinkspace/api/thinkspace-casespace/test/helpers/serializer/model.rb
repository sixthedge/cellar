module Test::Serializer::Model

  include ::Test::Casespace::Models

  extend ActiveSupport::Concern

  included do

    def serializer_space;        get_space(:serializer_space_1); end
    def serializer_assignment;   get_assignment(:serializer_assignment_1_1); end
    def serializer_phase;        get_phase(:serializer_phase_1_1_A); end
    def serializer_read_user;    get_user(:serializer_read_1); end
    def serializer_update_user;  get_user(:serializer_update_1); end

    def all_serializer_spaces; space_class.where(title: ['serializer_space_1', 'serializer_space_2']); end

    # Expects array values to be 'let' values.
    def serializer_models; [space, assignment, phase, user, get_space_user(space, user)]; end

    def phase_componentables_for_class(klass)
      phase.thinkspace_casespace_phase_components.where(componentable_type: klass.name).map(&:componentable)
    end

  end # included
end
