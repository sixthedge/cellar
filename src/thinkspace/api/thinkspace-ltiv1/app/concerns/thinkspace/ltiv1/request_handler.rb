module Thinkspace; module Ltiv1
  class RequestHandler < Totem::Authentication::Lti::RequestHandler

    # ### Thinkspace::Ltiv1::RequestHandler
    # ----------------------------------------
    #
    # This class extends the totem request handler to setup the assignment, space, and space_user


    # ### Attrs
    attr_accessor :assignment
    attr_accessor :space
    attr_accessor :space_user


    # ### Public Methods

    # Process
    # => Validate, setup all appropriate request data, and register contexts
    # => Return self
    def process
      raise RequestValidationError unless validate

      @roles      = get_roles
      @user       = get_or_create_user
      @resource   = get_resource
      @assignment = get_assignment
      @space      = get_space
      @space_user = get_or_create_space_user

      register
      self
    end

    def resource_link_is_assignment?; has_param?(OUTCOME_SERVICE_URL_KEY);  end
    def resource_link_is_space?;      !has_param?(OUTCOME_SERVICE_URL_KEY); end


    private


    # ### Helpers
    def resource_contextable_is_assignment?; resource.contextable_type == assignment_class.name; end
    def resource_contextable_is_space?;      resource.contextable_type == space_class.name;      end

    def get_space
      case
      when resource_contextable_is_space?
        resource.contextable
      when resource_contextable_is_assignment?
        resource.contextable.thinkspace_common_space
      end
    end

    def get_assignment
      case
      when resource_contextable_is_assignment?
        resource.contextable
      else
        nil
      end
    end

    def get_or_create_space_user
      space_user = space_user_class.find_or_create_by(user_id: user.id, space_id: space.id, role: get_space_role_name)
      space_user.state = 'active'
      space_user.save
      space_user
    end

    def get_space_role_name
      case 
      when is_instructor?
        'owner'
      else
        'read'
      end
    end


    # ### Classes
    def assignment_class; Thinkspace::Casespace::Assignment; end
    def space_class;      Thinkspace::Common::Space;         end
    def space_user_class; Thinkspace::Common::SpaceUser;     end

  end
end; end