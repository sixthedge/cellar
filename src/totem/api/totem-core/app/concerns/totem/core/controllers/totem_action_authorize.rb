module Totem
  module Core
    module Controllers
      module TotemActionAuthorize

        # Adds a class method to a controller class, that adds a before filter to authorize the record(s) and/or params.
        # Options:
        #   * Rails standard before_action options 'only', 'except', 'if', 'unless'
        #   * prepend:              [true|FALSE]
        #   * authable_name:        [string|symbol] default :authable
        #   * ownerable_name:       [string|symbol] default :ownerable
        #   * module:               [string|symbol|TRUE|false] default :action_authorize
        #   * module_before_method: [string|symbol] default :action_authorize!
        #   * module_method:        [string|symbol] default :action_authorize!
        #   * module_options:       [hash]
        #   * module_only:          [true|FALSE]
        #   * verify:               [true|FALSE]
        #   * params_priorify:      [:auth|:root] default :root (e.g. params_root for the record)
        #   * view_action:          [string|symbol]
        #   * view_update_action:   [string|symbol]
        #   * other keys:           e.g. :params_authable, etc.

        extend ::ActiveSupport::Concern

        module ClassMethods

          def totem_action_authorize!(*args)
            options       = args.extract_options!.symbolize_keys
            before_method = options[:prepend] ? :prepend_before_action : :before_action

            auth_module   = options.has_key?(:module) ? options[:module] : :action_authorize
            auth_module   = :action_authorize  if auth_module == true
            case
            when auth_module == false
            when auth_module.kind_of?(String)
              auth_mod = auth_module.safe_constantize
              raise "Authorize module #{auth_module.inspect} cannot be constantized."  if auth_mod.blank?
            when auth_module.kind_of?(Symbol)
              platform_name = ::Totem::Settings.engine.current_platform_name(self)
              raise "Platform name not defined for #{self.inspect}."  if platform_name.blank?
              auth_mod = ::Totem::Settings.module.send(platform_name).send(auth_module)
            else
              raise "Options auth_module must be either a string or symbol."
            end

            self.send(before_method, options.slice(:only, :except, :if, :unless)) do |controller|
              controller.send(:totem_action_authorize!, auth_mod, options)
            end
          end

        end

        private

        attr_reader :totem_action_authorize

        def totem_action_authorize!(auth_mod, options={})
          @totem_action_authorize = Authorize.new(self, auth_mod, options)
          totem_action_authorize.process
        end

        # ################ #
        # Authorize Class. #
        # ################ #

        # Encapsulate the authorization methods to prevent any collisions with existing controller methods.
        # The platform specific authorize module only has access to methods in this class.
        # CAUTION: The platform specific authorize module can override the instance methods in this class.
        #          Good if by design, but bad if accidental.  Recommend to have a platform specific
        #          string in the platform module's method names to prevent accidental overrides.
        class Authorize

          class MethodMissing  < StandardError; end
          class OptionError    < StandardError; end
          class AuthorizeError < StandardError; end

          attr_reader :controller  # current controller instance
          attr_reader :options     # totem_action_authorize! options

          attr_reader :auth_module_included           # whether a platform authorize module was included (true|false)
          attr_reader :auth_module_name               # platform authorize module's name
          attr_reader :auth_module_controller_method  # method derived from the controller class name with underscores (and without ending 'controller')

          attr_reader :authable_name    # authable polymorphic name  (default :authable)
          attr_reader :ownerable_name   # ownerable polymorphic name (default :ownerable)

          attr_reader :authable_ability
          attr_reader :ownerable_ability

          attr_reader :current_record   # member route record
          attr_reader :current_scope    # collection route records scope when params[:ids]
          attr_reader :current_records  # collection route records scope.find(params[:ids])

          attr_reader :record_authable, :record_ownerable
          attr_reader :params_authable, :params_ownerable

          attr_reader :can_update_record_authable # whether the current_user can update the record's authable (true|false)

          attr_reader :view_action             # ability action name when can read authable
          attr_reader :view_update_action      # ability action name when can update authable

          attr_reader :view_actions            # view controller actions
          attr_reader :read_actions            # read controller actions
          attr_reader :sub_action              # params[:auth] sub_action

          # Set for a view action.
          attr_reader :params_view_ids         # params[:view_ids]
          attr_reader :params_view_class       # params_ownerable.class
          attr_reader :params_view_class_name  # params_ownerable.class.name
          attr_reader :view_ability_action     # [:view|:view_update] depending whether the current user can update the authable

          attr_reader :authable_ability_action         # ability action to validate current user can 'action' the authable  (default :read)
          attr_reader :ownerable_ability_action        # ability action to validate current user can 'action' the ownerable (default :read)
          attr_reader :authable_ability_update_action  # ability action used to set can-update-authable (default :update)

          # ###
          # ### Initialize.
          # ###

          def initialize(controller, auth_mod, options={})
            @controller = controller
            @options    = options

            # Set option key value as a symbol (or the default).
            @authable_name                  = string_or_symbol_option_to_sym(:authable_name, :authable)
            @ownerable_name                 = string_or_symbol_option_to_sym(:ownerable_name, :ownerable)
            @authable_ability_action        = string_or_symbol_option_to_sym(:authable_ability_action, :read)
            @authable_ability_update_action = string_or_symbol_option_to_sym(:authable_ability_update_action, :update)
            @ownerable_ability_action       = string_or_symbol_option_to_sym(:ownerable_ability_action, :read)
            @view_action                    = string_or_symbol_option_to_sym(:view_action, :view)
            @view_update_action             = string_or_symbol_option_to_sym(:view_update_action, :view)
            @read_actions                   = [:index, :show, :select, :view] + [options[:read]].flatten.compact.map {|a| a.to_sym}
            @view_actions                   = [:view] + [options[:view]].flatten.compact.map {|a| a.to_sym}
            @authable_ability               = Hash.new(false)
            @ownerable_ability              = Hash.new(false)


            if auth_mod.present? # add the platform specific authorize module methods to this class
              extend auth_mod
              @auth_module_name              = auth_mod.name
              @auth_module_included          = true
              @auth_module_controller_method = controller.class.name.sub(/Controller$/,'').underscore.gsub('/','_').to_sym
            end

          end

          def string_or_symbol_option_to_sym(key, default=nil)
            value = options[key] || default
            raise OptionError, "Value for options[#{key.inspect}] must be a string or symbol not #{value.class.name.inspect}."  unless ( value.instance_of?(Symbol) || value.instance_of?(String) )
            value.to_sym
          end

          # Methods overriden in platform authorize module.
          def action_authorize!;           raise MethodMissing, "Method 'action_authorize!' not defined."; end
          def authorize_authable_classes;  raise MethodMissing, "Method 'authorize_authable_classes' not defined."; end
          def authorize_ownerable_classes; raise MethodMissing, "Method 'authorize_ownerable_classes' not defined."; end

          # Options access/helper methods.
          def debug?;               (options[:debug] == true || debug_to_log?); end
          def debug_to_log?;         options[:debug_to_log]    == true; end
          def verify?;               options[:verify]          == true; end
          def params_priority_auth?; options[:params_priority] == :auth; end
          def module_only?;          options[:module_only]     == true; end
          def module_options;        options[:module_options] || {}; end
          def module_method;         options[:module_method]  || :action_authorize!; end
          def module_before_method;  options[:module_before_method] || false; end

          # Controller access methods.  Using methods so only initialized when used.
          def current_user;     @current_user     ||= controller.send(:current_user); end
          def current_ability;  @current_ability  ||= controller.send(:current_ability); end
          def params;           @params           ||= controller.params; end
          def params_data;      @params_data      ||= params[:data] || {}; end
          def params_root;      @params_root      ||= params_data[:attributes] || {}; end
          def action;           @action           ||= controller.action_name.to_sym; end
          def model_class_name; @model_class_name ||= controller.send(:controller_model_class_name); end
          def model_class;      @model_class      ||= controller.send(:controller_model_class); end

          # Pass through ability can? requests to controller.
          def can?(*args); controller.can?(*args); end
          def authorize!(*args); controller.authorize!(*args); end

          # Ability helpers.
          def can_update_record_authable?; can_update_record_authable; end
          def set_authable_ability(ability);  authable_ability.merge!(ability.symbolize_keys); end
          def set_ownerable_ability(ability); ownerable_ability.merge!(ability.symbolize_keys); end

          # General helpers.
          def is_create?; action == :create; end
          def is_view?;   view_actions.include?(action); end
          def is_read?;   read_actions.include?(action); end
          def is_modify?; !is_read?; end

          def has_view_ids?; params_view_ids.present?; end
          def auth_module_included?; auth_module_included; end
          def self_respond_to?(method); self.respond_to?(method, true); end

          def msg_id(record);       "[id: #{record.respond_to?(:id) ? record.id : record}]"; end
          def msg_class_id(record); "[#{record.class.name} id: #{record.respond_to?(:id) ? record.id : record}]"; end

          # ###
          # ### MAIN process method.
          # ###

          # If options[:module_only] = true, no base class authorize methods are called,
          # only the module's authorize method, otherwise the standard action based authorize
          # methods are called before the module's authorize method (if it was included).
          #
          # If present, the options[:module_before_method] will be called before processing.
          # This can be used to alter instance values before processing begins (e.g. params, options, etc.).
          # Caution should be used when doing this.
          #
          def process
            process_platform_authorize_module_before_method
            if module_only?
              debug_message('-module only', "No default processing performed.")  if debug?
              process_platform_authorize_module
            else
              process_authorize
            end
          end

          # ###
          # ### Call the platform specific 'before' authorize module method.
          # ###

          def process_platform_authorize_module_before_method
            return if module_before_method.blank?
            access_denied("Authorize module '#{auth_module_name}' does not respond to 'before' method #{method.inspect}.")  unless self_respond_to?(module_before_method)
            debug_message('>calling before', "#{auth_module_name}##{module_before_method}")  if debug?
            self.send module_before_method  # call the platform spcific authorize module's before method
          end

          # ###
          # ### Call the platform specific authorize module method.
          # ###

          # Unless options[:module] = false (e.g. no auth module loaded), call the platform authorize module's method.
          #
          # A module is called once based on the following order (when the module responds to the method):
          #  1. Controller method name (e.g. controller class name with underscores and without the ending 'controller').
          #  2. options[:module_method] value (or default :action_authorize!).
          #  3. Access denied.
          #
          def process_platform_authorize_module
            if auth_module_included?
              method = auth_module_controller_method   # first attempt the module method that matches the controller class name
              method = module_method  unless self_respond_to?(method)
              access_denied("Authorize module '#{auth_module_name}' does not respond to #{method.inspect}.")  unless self_respond_to?(method)
              debug_message('>calling method', "#{auth_module_name}##{method}")  if debug?
              self.send method  # call the platform spcific authorize module's method
            else
              debug_message('-no auth module', "No platform authorize module implemented.")  if debug?
            end
          end

          # ###
          # ### Determine what to authorize.
          # ###

          def process_authorize

            case

            when is_create?
              set_current_record
              process_params
              process_record_association_attributes
              process_action_authorize # do after associations established
              process_record
              verify_record
              process_platform_authorize_module

            # Do before params[:id] check since view_ids will also have an id.
            when is_view?
              set_current_record
              process_action_authorize
              process_view_action
              process_params
              process_record
              verify_record
              @view_ability_action = can_update_record_authable? ? view_update_action : view_action
              access_denied(current_record, "View ability action is blank.")  if view_ability_action.blank?
              debug_message('#view ability', "set to [#{view_ability_action.inspect}].")   if debug?
              process_platform_authorize_module

            when params[:id].present?
              set_current_record
              process_action_authorize
              process_params
              process_record
              verify_record
              process_platform_authorize_module

            when (ids = params[:ids]).present?
              set_current_records(ids)
              process_params
              current_records.each do |record|
                @current_record = record
                process_action_authorize
                process_record
                verify_record
                process_platform_authorize_module
                debug_message('-------')  if debug? && current_records.many?
              end

            else
              set_params_authable  if has_params_model_type_or_model_id_for_key?(authable_name)
              set_params_ownerable if has_params_model_type_or_model_id_for_key?(ownerable_name)
              set_params_sub_action
              process_platform_authorize_module
            end

          end

          # ###
          # ### View action model type and ids.
          # ###

          def process_view_action
            view_type, view_ids = get_auth_params_view_model_type_and_ids
            access_denied(current_record, "Action view params[:auth][:view_type] is blank.")  if view_type.blank?
            access_denied(current_record, "Action view params[:auth][:view_ids] are blank.")  if view_ids.blank?
            view_type_class = get_model_type_class(view_type)
            access_denied(current_record, "Action view params[:auth][view_type: #{view_type.inspect} cannot be constantized.")  if view_type_class.blank?
            access_denied("Invalid view action class #{view_type_class.name}.")  unless valid_ownerable_class?(view_type_class)
            @params_view_ids        = [view_ids].flatten.compact
            @params_view_class      = view_type_class
            @params_view_class_name = view_type_class.name  # convience for where(ownerable_type: params_view_class_name)
            debug_message('*params_view_class', "set to class [#{params_view_class.name}].")  if debug?
            debug_message('*params_view_ids',   "set to ids #{params_view_ids}.")           if debug?
          end

          # ###
          # ### Authorize action on current_record when skipped in cancan (e.g. only/except action).
          # ###

          def process_action_authorize
            if skipped_authorize_action?
              access_denied(current_record, "Do not have ability to #{action.inspect} [#{current_record.class.name}].")  unless can?(action, current_record)
              debug_message('<authorize action', "authorizing skipped action #{action.inspect} on [#{current_record.class.name} id=#{current_record.id.inspect}].")  if debug?
            end
          end

          # This is specific to CanCan 1.16.10.
          def skipped_authorize_action?
            return true unless controller.class.respond_to?(:cancan_skipper)  # authorize the action if does not have cancan skipper
            cancan_skipper = controller.class.cancan_skipper[:authorize]
            cancan_skipper.each do |key, values|
              return true if values.has_key?(:only)   && [values[:only]].flatten.include?(action)
              return true if values.has_key?(:except) && ![values[:except]].flatten.include?(action)
            end
            false
          end

          # ###
          # ### Combine common process methods with options check.
          # ###

          # Set the authable and ownerable from the 'params' hash model type and id.
          #
          # If options[:params_priority] != :auth, then the type and id are first taken from
          # the record params and if blank, taken from the param[:auth] (e.g. record's hash) (and vice-versa).
          #
          # In a create action, the 'params' authable and ownerable is used to set the record's
          # polymorphic association (if they exist).
          # An access_denied is raised if a record has the association and corresponding
          # params authable/ownerable does not exist.
          #
          # In a view action, the 'params_ownerable' is used to set the view class.
          # An access_denied is raised if the params_ownerable does not exist.
          #
          # If options[:verfiy] = true, both the 'params_authable' and 'params_ownerable'
          # will be checked against the record's authable and ownerable (if they exist).
          # An access_denied is raised if they do not match.
          #
          def process_params
            set_params_authable   if process_params_authable?
            set_params_ownerable  if process_params_ownerable?
            set_params_sub_action
          end

          # Poplulate a record's associations from the params values.  Normally only done
          # in a create record action.
          #
          # For new records, this process must be done to set the new record's associations
          # before attempting to get a record's authable/ownerable.
          #
          def process_record_association_attributes
            set_record_association_attributes  if process?(:record_attributes)
          end

          # Set the 'record_authable' and 'record_ownerable' from the record's associations.
          #
          # The record's authable/ownerable may be either a polymorphic association defined
          # in the record's model or may be delegated to an associated record.
          #
          def process_record
            set_record_authable   if process_record_authable?
            set_record_ownerable  if process_record_ownerable?
          end

          # Compare the 'params' authable/ownerable against the record's authable/ownerable.
          #
          # Also ensure a record's 'user_id' is set to the current_user.id.
          #
          def verify_record
            verify_record_authable   if verify_record_authable?
            verify_record_ownerable  if verify_record_ownerable?
            verify_record_user       if verify_record_user?
          end

          # ###
          # ### Checks to determine whether to process an authorize method.
          # ###

          # Typically, options are defaulted to 'true' by not including a key in the options.
          def process?(key)
            return true unless options.has_key?(key)  # default to true
            value = options[key]
            return false if value == false
            return true  if value == true
            [value].flatten.compact.map {|a| a.to_sym}.include?(action)  # only process for certain controller actions
          end

          def process_params_authable?
            return false unless process?(:params_auth)
            return false unless process?(:params_authable)
            return true  if options[:params_authable_required] == true
            return true  if is_create? && record_has_authable_polymorphic?
            return true  if has_params_model_type_or_model_id_for_key?(authable_name)
            return true  if verify?
            false
          end

          def process_params_ownerable?
            return false unless process?(:params_auth)
            return false unless process?(:params_ownerable)
            return false unless process?(:params_ownerable_required)
            return true  if has_params_model_type_or_model_id_for_key?(ownerable_name)
            return true  if record_has_authable_polymorphic?  # authable records typically require an ownerable (disable with option 'params_ownerable_required')
            return true  if verify?
            false
          end

          def process_record_authable?
            return false unless process?(:record_authable)
            record_respond_to_authable?
          end

          def process_record_ownerable?
            return false unless process?(:record_ownerable)
            record_respond_to_ownerable?
          end

          def verify_record_authable?
            return false unless ( verify? && process?(:verify_record_authable) )
            record_authable.present? && params_authable.present?
          end

          def verify_record_ownerable?
            return false unless ( verify? && process?(:verify_record_ownerable) )
            record_ownerable.present? && params_ownerable.present?
          end

          def verify_record_user?
            return false unless ( verify? && process?(:verify_record_user) )
            current_record.has_attribute?(:user_id)
          end

          # respond_to? is true if the record has the polymophic or 'delegates' the polymorphic.
          def record_respond_to_ownerable?(record=current_record);     record.respond_to?(ownerable_name); end
          def record_respond_to_authable?(record=current_record);      record.respond_to?(authable_name); end

          # Check if the record has the belongs_to polymophic (e.g. not 'delegated').
          def record_has_authable_polymorphic?(record=current_record);  record_has_polymorphic_association?(authable_name, record); end
          def record_has_ownerable_polymorphic?(record=current_record); record_has_polymorphic_association?(ownerable_name, record); end

          def record_has_polymorphic_association?(assoc_key, record=current_record)
            return false if record.blank?
            assoc = record.class.reflect_on_association(assoc_key)
            return false if assoc.blank?
            assoc.macro == :belongs_to && assoc.options[:polymorphic]
          end

          # ###
          # ### Set the current record (member route) from the controller's instance variable.
          # ###

          def set_current_record
            record_var      = '@' + model_class.name.demodulize.underscore
            @current_record = controller.instance_variable_get(record_var)
            access_denied("Instance variable for record #{record_var.inspect} is blank.")  if current_record.blank?
            debug_message('#current_record', "set to #{msg_class_id current_record} from #{record_var}.")  if debug?
          end

          # ###
          # ### Set the current scope and current records (collection route) from the controller's instance variable and params ids.
          # ###

          def set_current_records(ids)
            access_denied("Params record ids are blank.")  if ids.blank?
            record_var     = '@' + model_class.name.demodulize.underscore.pluralize
            @current_scope = controller.instance_variable_get(record_var)
            access_denied("Instance variable for record scope #{record_var.inspect} is blank.")  if current_scope.blank?
            @current_records = current_scope.find(ids)
            controller.instance_variable_set(record_var, current_records)
            debug_message('#current_records', "set to [#{current_records.first.class.name}] [ids: #{ids}] and set to #{record_var}.")  if debug?
          end

          # ###
          # ### Set the params values (either from the record's params attributes or from params[:auth]).
          # ###

          def set_params_authable
            type, id, source = get_params_model_type_and_id_for_key(authable_name)
            access_denied("'authable' type in [#{source}] is blank.")  if type.blank?
            access_denied("'authable' id in [#{source}] is blank.")    if id.blank?
            @params_authable = current_ability.get_record_by_model_type_and_model_id(type, id)
            debug_message('*params_authable', "set to #{msg_class_id params_authable} source: [#{source}].")  if debug?
            access_denied("Invalid [#{source}] authable class #{params_authable.class.name}.")  unless valid_authable_class?(params_authable)
          end

          def set_params_ownerable
            type, id, source = get_params_model_type_and_id_for_key(ownerable_name)
            access_denied("'ownerable' type in [#{source}] is blank.")  if type.blank?
            access_denied("'ownerable' id in [#{source}] is blank.")    if id.blank?
            @params_ownerable = current_ability.get_record_by_model_type_and_model_id(type, id)
            debug_message('*params_ownerable', "set to #{msg_class_id params_ownerable} source: [#{source}].")  if debug?
            access_denied("Invalid [#{source}] ownerable class #{params_ownerable.class.name}.")  unless valid_ownerable_class?(params_ownerable)
          end

          # ###
          # ### Set params sub_action.
          # ###

          def set_params_sub_action
            @sub_action = get_params_sub_action
          end

          # ###
          # ### Set the record's authable.
          # ###

          def set_record_authable(record=current_record)
            access_denied("Record in set_record_authable is blank.")       if record.blank?
            access_denied(record, "Record does not respond to authable.")  unless record_respond_to_authable?(record)
            @record_authable = record.send(authable_name)
            access_denied(record, "Record authable is blank.")  if record_authable.blank?
            debug_message('#record_authable', "set to #{msg_class_id record_authable}.")  if debug?
            access_denied(record, "Invalid record authable class #{record_authable.class.name}.")  unless valid_authable_class?(record_authable)
            access_denied(record, "User cannot read authable #{msg_class_id record_authable}.")   unless can?(authable_ability_action, record_authable)
            debug_message('@authable_auth?', "user can [#{authable_ability_action.inspect}] authable.")  if debug?
            @can_update_record_authable = can?(authable_ability_update_action, record_authable)
            set_authable_ability(authable_ability_update_action => can_update_record_authable)
            debug_message('@update_authable?', "set to [#{can_update_record_authable.inspect}] action [#{authable_ability_update_action.inspect}].")  if debug?
          end

          # Validate the authable class matches one of the platform's allowed authable classes.
          def valid_authable_class?(authable)
            return true unless auth_module_included?
            access_denied("Authable is blank in verify_authable_class.")  if authable.blank?
            classes = authorize_authable_classes
            access_denied("Platform authable classes are blank.")  if classes.blank?
            authable_class = authable.kind_of?(Class) ? authable : authable.class
            [classes].flatten.include?(authable_class)
          end

          # ###
          # ### Set the record's ownerable.
          # ###

          def set_record_ownerable(record=current_record)
            access_denied("Record in set_record_ownerable is blank.")       if record.blank?
            access_denied(record, "Record does not respond to ownerable.")  unless record_respond_to_ownerable?(record)
            @record_ownerable = record.send(ownerable_name)
            access_denied(record, "Record ownerable is blank.")  if record_ownerable.blank?
            debug_message('#record_ownerable', "set to #{msg_class_id record_ownerable}.")  if debug?
            access_denied(record, "Invalid record ownerable class #{record_ownerable.class.name}.")  unless valid_ownerable_class?(record_ownerable)
            access_denied(record, "User cannot [#{ownerable_ability_action.inspect}] ownerable #{msg_class_id record_ownerable}.")   unless can?(ownerable_ability_action, record_ownerable)
            debug_message('@ownerable_auth?', "user can [#{ownerable_ability_action.inspect}] ownerable.")  if debug?
          end

          # Validate the ownerable class matches one of the platform's allowed ownerable classes.
          def valid_ownerable_class?(ownerable)
            return true unless auth_module_included?
            access_denied("Ownerable is blank in verify_ownerable_class.") if ownerable.blank?
            classes = authorize_ownerable_classes
            access_denied("Platform ownerable classes are blank.")  if classes.blank?
            ownerable_class = ownerable.kind_of?(Class) ? ownerable : ownerable.class
            [classes].flatten.include?(ownerable_class)
          end

          # ###
          # ### Update a record's 'belong_to' associations from the params.
          # ###

          def set_record_association_attributes(record=current_record)
            access_denied("Record in set_record_association_attributes is blank.")  if record.blank?
            associations = record.class.reflect_on_all_associations(:belongs_to)
            associations.each do |assoc|
              foreign_key = assoc.foreign_key
              name        = assoc.name
              polymorphic = assoc.options[:polymorphic] || false
              case
              when foreign_key == 'user_id'
                record.user_id = current_user.id
                debug_message('+record.user_id', "set to current_user #{msg_id current_user}.")  if debug?
              when name == authable_name && polymorphic
                access_denied(record, "Record has authable association but params_authable is blank.")  if params_authable.blank?
                record.send "#{authable_name}=", params_authable
                debug_message('+record.authable', "set to #{msg_class_id params_authable}.")  if debug?
              when name == ownerable_name && polymorphic
                access_denied(record, "Record has ownerable association but params_ownerable is blank.")  if params_ownerable.blank?
                record.send "#{ownerable_name}=", params_ownerable
                debug_message('+record.ownerable', "set to #{msg_class_id params_ownerable}.")  if debug?
              when is_create? && polymorphic
                model_type, model_id = get_record_params_model_type_and_id_for_key(name)
                if model_type.blank? && model_id.blank? && blank_association_allowed?(name)
                  debug_message("-record.association", "polymorphic association name '#{name}' is blank and allowed to be blank.")  if debug?
                  next
                end
                model_class = get_model_type_class(model_type)
                record.send("#{name}_type=", model_class.name)
                access_denied(record, "Record has polymorphic association #{name.inspect} but params_root id is blank.")  if model_id.blank?
                record.send("#{name}_id=", model_id)
                debug_message("+record.#{name}", "polymorphic set to [#{model_class.name} id=#{model_id}].")  if debug?
              when !polymorphic
                method = "#{foreign_key}="
                path   = assoc.options[:class_name].deconstantize.underscore + "/#{foreign_key}"
                id     = controller.params_association_path_id(path)
                if id.blank?
                  if blank_association_allowed?(foreign_key)
                    record.send(method, nil)
                    debug_message("-record.association", "'#{foreign_key}' is blank and allowed to be blank.")  if debug?
                    next
                  end
                  access_denied(record, "Record has a blank association #{path.inspect} and it is not allowed.")
                end
                record.send(method, id)
                debug_message("+record.association", "'#{foreign_key}' set to [id=#{id}].")  if debug?
              end
            end
          end

          def blank_association_allowed?(assoc)
            @allow_blank_associations ||= (options[:allow_blank_associations] || Hash.new)
            access_denied(record, "Options 'allow_blank_associations' is not a hash [#{@allow_blank_associations.inspect}].")  unless @allow_blank_associations.kind_of?(Hash)
            [@allow_blank_associations[action]].flatten.include?(assoc.to_sym)
          end

          # ###
          # ### Verify the current record's associations are the same as the params record's associations.
          # ###

          def verify_record_authable(valid_authable=params_authable, authable=record_authable, record=current_record)
            access_denied("Record in verify_record_authable is blank.")  if record.blank?
            validate_same_record(valid_authable, authable, record, authable_name)
            debug_message('=record.authable', "verified to be [#{valid_authable.class.name} id=#{valid_authable.id.inspect}].")  if debug?
          end

          def verify_record_ownerable(valid_ownerable=params_ownerable, ownerable=record_ownerable, record=current_record)
            access_denied("Record in verify_record_ownerable is blank.")  if record.blank?
            validate_same_record(valid_ownerable, ownerable, record, ownerable_name)
            debug_message('=record.ownerable', "verified to be [#{valid_ownerable.class.name} id=#{valid_ownerable.id.inspect}].")  if debug?
          end

          def verify_record_user(record=current_record, user=current_user)
            access_denied("Record in verify_record_user is blank.")        if record.blank?
            access_denied("Current user in verify_record_user is blank.")  if user.blank?
            access_denied(record, "User_#{msg_id record.user_id} does not match current_user #{msg_id current_user}.")  unless record.user_id == current_user.id
            debug_message('=record.user_id', "verified to be set to current user #{msg_id current_user}.")  if debug?
          end

          # ###
          # ### Model type and model id from the params.
          # ### Either from the params record path or params[:auth] based on options[:params_priority] value.
          # ###

          def has_params_model_type_or_model_id_for_key?(key)
            type, id, source = get_params_model_type_and_id_for_key(key)
            type.present? || id.present?
          end

          def get_params_model_type_and_id_for_key(key)
            if params_priority_auth?
              source   = 'params[:auth]'
              type, id = get_auth_params_model_type_and_id_for_key(key)
              if type.blank? && id.blank?
                source += ' -- params_root'
                type, id = get_record_params_model_type_and_id_for_key(key)
              end
            else
              source   = 'params_root'
              type, id = get_record_params_model_type_and_id_for_key(key)
              if type.blank? || id.blank?
                source   += ' -- params[:auth]'
                type, id = get_auth_params_model_type_and_id_for_key(key)
              end
            end
            [type, id, source]
          end

          def get_auth_params_model_type_and_id_for_key(key)
            hash_model_type_and_id_for_key(params[:auth] || {}, key)
          end

          def get_record_params_model_type_and_id_for_key(key)
            hash_model_type_and_id_for_key(params_root, key)
          end

          def hash_model_type_and_id_for_key(hash, key)
            [ hash["#{key}_type"], hash["#{key}_id"] ]
          end

          def get_auth_params_view_model_type_and_ids
            view_params = params[:auth] || {}
            [ view_params[:view_type], view_params[:view_ids] ]
          end

          def get_params_sub_action
            sub_action = params[:auth] && params[:auth][:sub_action]
            return nil if sub_action.blank?
            sub_action.to_sym
          end

          # ###
          # ### General helpers.
          # ###

          def get_model_type_class(model_type)
            access_denied "Model type #{model_type.inspect} is not a string"  unless model_type.instance_of?(String)
            model_type  = model_type.gsub('.', '::').classify
            model_type.safe_constantize
          end

          def validate_same_record(record_1, record_2, record=current_record, name='')
            return if is_same_record?(record_1, record_2)
            access_denied(record, "Record 1 is blank. [record_2: #{record_2.inspect}]")  if record_1.blank?
            access_denied(record, "Record 2 is blank. [record_1: #{record_1.inspect}]")  if record_2.blank?
            name = name.present? ? "#{name.to_s.humanize} " : ''
            access_denied(record, "#{name} #{msg_class_id record_1} does not match #{msg_class_id record_2}.")
          end

          def is_same_record?(record_1, record_2)
            return false if record_1.blank? || record_2.blank?
            record_1.class.name == record_2.class.name && record_1.id == record_2.id
          end

          # access_denied(authable, 'message', options)
          # No arguments are required.
          # Examples:
          #  access_denied authable, 'message', user_message: 'friendly message', ownerable: msg_class_id(ownerable)
          #  access_denied 'message', user_message: 'friendly message', ownerable: msg_class_id(ownerable)
          #  access_denied authable, user_message: 'friendly message'
          #  access_denied user_message: 'friendly message'
          #  access_denied
          def access_denied(*args)
            options = args.extract_options!
            record  = args.shift
            message = args.shift
            if message.blank? && record.instance_of?(String)
              message = record
              record  = nil
            end
            options[:message]  = message  if message.present?
            options[:authable] = msg_class_id(record) if record.present?
            debug_message "[debug-authorize] Access denied message: [#{message.inspect}] [#{options.inspect}]" if debug?
            subject = current_record.present? ? msg_class_id(current_record) : model_class
            controller.send(:raise_access_denied_exception, nil, action, subject, options)
          end

          # ### Format Date/Time (local date/time).

          def fmt_time(time, fmt='%B %e, %Y %l:%M%P %Z')   # default fmt: January 1, 2015 10:10am
            local_time = time.blank? || !time.kind_of?(Time) ? Time.now : time.localtime
            local_time.strftime(fmt)
          end

          def fmt_date(date, fmt='%B %e, %Y')   # default fmt: January 1, 2015
            case
            when date.blank?
              local_date = Date.current
            when date.kind_of?(Time)
              local_date = date.localtime
            when date.kind_of?(Date)
              local_date = date
            else
              local_date = Date.current
            end
            local_date.strftime(fmt)
          end

          # ### Debug.

          def debug_message(message_key, message='')
            if message.blank?
              message     = message_key
              message_key = ''
            else
              message_key = "#{message_key}".ljust(20)
            end
            @debug_message_count ||= 0
            puts "\n"  if @debug_message_count == 0
            @debug_message_count += 1
            name = controller.class.name.demodulize.sub(/Controller$/,'')
            msg  = "[debug-authorize] [#{name}##{action}] #{message_key}#{message}"
            puts msg
            debug_message_to_log(msg)  if debug_to_log?
          end

          def debug_message_to_log(message); ::Rails.logger.debug message; end

        end

      end
    end
  end
end
