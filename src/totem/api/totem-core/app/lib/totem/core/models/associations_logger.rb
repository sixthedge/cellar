module Totem
  module Core
    module Models
      module AssociationsLogger

        attr_reader :warnings

        # ######################################################################################
        #                       LOGGING FOR RAKE TASK                                          #
        # ######################################################################################
        # @!group Log Associations

        def log_model_separator(model=nil)
          return unless log_class?(model.name)
          log "\n"
          log "[#{model.name}]"  if log_clean? && model.present?
        end

        def log_serializer_separator(model, serializer=nil)
          return unless log_class?(model.name)
          log '  --'  unless log_clean?
          log "  $ [#{serializer.name}]"  if log_clean? && serializer.present?
        end

        def log_model_association(model, type, assoc_name, options)
          return unless log_class?(model.name)
          if log_clean?
            log "  > #{type} #{assoc_name.inspect}"
            log_options(options, '    ')
          else
            log "Model [#{model.name}] [#{type}] association [#{assoc_name.inspect}] added with options #{options.inspect}"
          end
        end

        def log_serializer_association(model, type, serializer, assoc_name, options={})
          return unless log_class?(model.name)
          if log_clean?
            log "    > #{type} #{assoc_name.inspect}"
            log_options(options, '      ', 7)
          else
            log "Model [#{model.name}] Serializer [#{serializer.name}] [#{type}] association [#{assoc_name.inspect}] added with options #{options.inspect}"
          end
        end

        def log_serializer_method(model, type, serializer, assoc_name, options={})
          return unless log_class?(model.name)
          if log_clean?
            log "      #{type} #{assoc_name.inspect}"
          else
            log "Model [#{model.name}] Serializer [#{serializer.name}] add method [#{type}] for association [#{assoc_name.inspect}]"
          end
        end

        def log_options(options, pad='', ljust=12)
          return unless options.present? && options.kind_of?(Hash)
          keys        = options.keys.sort
          keys.each do |key|
            log "#{pad}- #{key.inspect.ljust(ljust)} = #{options[key].inspect}"
          end
        end

        # ######################################################################################
        # @!group Rake Task

        # rake task options:
        #   LIST='class1, class2,...'  #=> must match one of the class names
        #   LIKE='partial-class1, partial_class2,...'  #=> must 'start_with' one of the partial class names
        def check_rake_task
          @is_rake_task = ($0 =~ /rake$/)
          if is_rake_task?
            task_name = ENV['TASKNAME']
            task_name = task_name.present? ? task_name.downcase : ''
            if task_name.match('association:list')
              set_log_on
              set_log_clean_on unless task_name.match(':full')
              @is_rake_association_task = true
              @warnings    = []
              @log_classes = []
              list_classes = ENV['LIST'] || ENV['LIKE']
              if list_classes.present?
                @log_classes = list_classes.split(',').collect {|c| c.strip}.compact
                @log_classes_like = ENV['LIKE'].present?
              end
            end
          end
        end

        def is_rake_task?
          @is_rake_task
        end

        def is_rake_association_task?
          is_rake_task? && @is_rake_association_task
        end

        # ######################################################################################
        # @!group Log Utility

        def set_log_on
          @log = true
        end

        def set_log_clean_on
          @log_clean = true
        end

        def log?
          @log
        end

        def log_clean?
          @log_clean
        end

        def log_class?(model_class)
          return true unless @log_classes.present?
          return @log_classes.include?(model_class) if not @log_classes_like
          @log_classes.each do |log_class|
            return true if model_class.start_with?(log_class)
          end
          false
        end

        def log(message)
          if log_clean?
            puts message
            Rails.logger.info message
          else
            message = "[INFO] #{self.class}: #{message}"
            puts message
            Rails.logger.info message
          end
        end

      end

    end
  end
end
