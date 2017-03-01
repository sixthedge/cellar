module Totem
  module Core
    module Support
      module Shared

        def shared_engine_path_to_engine_name(path)
          totem_settings.engine.to_engine_name(path)
        end

        # Expand engine paths with a wildcard ('*') at the end to include matching engine names.
        # Passed in 'paths' must be an array of 'all' paths (wildcard paths and non-wildcard paths).
        # If a path matches a wildcard but is already in the paths it will not be
        # duplicated in the returned expanded array.  New matching paths are added at
        # the wildcard path location.
        def shared_expand_wildcard_engine_paths(paths)
          expanded_paths = Array.new
          paths.each do |path|
            if path.ends_with?('*')
              shared_add_matching_engine_paths(path.chop, expanded_paths, paths)
            else
              expanded_paths.push path
            end
          end
          expanded_paths
        end

        def shared_add_matching_engine_paths(path, expanded_paths, paths)
          engine_name    = shared_engine_path_to_engine_name(path)
          matching_names = totem_settings.engine.find_by_starts_with(engine_name) || []
          warning "No engines match the wildcard path [#{path}*]"  if matching_names.blank?
          engine_name_and_class = totem_settings.engine.name_and_class
          matching_names.sort.each do |match_name|
            match_class = engine_name_and_class[match_name]
            error "Engine name [#{match_name}] does not have an engine class"  if match_class.blank?
            match_path = match_class.underscore
            next if paths.include?(match_path)
            expanded_paths.push match_path
          end
        end

        def shared_configuration_files(search_dirs, file_ext, options={})
          filename    = options[:filename] || 'config_files'
          relative_to = options[:relative_to]
          file_search = Array.new
          [search_dirs].flatten.each do |search_dir|
            file = File.join(search_dir, filename)
            if File.exist?(file)
              # If the search_dir/filename exists, use its content for the file paths.
              # This allows using using a local repo's config file.
              content = File.read(file)
              content.each_line do |dir|
                dir = dir.strip
                next if dir.blank? || dir.starts_with?('#')
                full_path = relative_to.present? ? File.join(relative_to, dir, file_ext) : File.join(dir, file_ext)
                file_search.push full_path
              end
            else
              file_search.push File.join(search_dir, file_ext)
            end
          end
          file_search.blank? ? [] : Dir[*file_search]
        end

        # ######################################################################################
        # @!group Messages

        def startup_quiet?; ::Totem::Settings.config.startup_quiet?; end

        def print_message_on_console(message)
          puts message
        end

        def message_class_name
          self.kind_of?(Class) ? self.name : self.class.name
        end

        def info(message)
          return if startup_quiet?
          message = "[info] #{message}"
          print_message_on_console message  unless logger_broadcasts_to_console?
          logger.info message
        end

        def debug(message)
          return if startup_quiet?
          message = "[debug] #{message}"
          print_message_on_console message  unless logger_broadcasts_to_console?
          logger.debug message
        end

        def warning(message)
          message = "[WARNING] #{message_class_name}: #{message}"
          print_message_on_console message  unless logger_broadcasts_to_console?
          logger.warn message
        end

        def error(message)
          message = "[ERROR] #{message_class_name}: #{message}"
          logger.error message
          raise message
        end

        def logger
          Rails.logger
        end

        def logger_broadcasts_to_console?
          # Goal: prevent double debug console messages.
          # Hackish way to determine whether Rails has set the logger to broadcast to the console.
          ::Rails.constants.include?(:BacktraceCleaner) || ::Rails.constants.include?(:ConsoleMethods)
        end

      end
    end
  end
end
