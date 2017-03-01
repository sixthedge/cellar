module Totem
  module Cli
    module Helpers
      module Doc

        def self.included(base)
          return unless base.ancestors.include?(Thor::Group)
          base.class_eval do
            class_option :overview, type: :boolean, default: false, aliases: '-O', desc: 'overview help'
            class_option :examples, type: :boolean, default: false, aliases: '-E', desc: 'usage examples help'

            def base.doc_banner_run_options
              doc_run_options = <<DOC_RUN_OPTIONS

  If running multiple times, recommend using the option --run-options-filename [-o, -O] that points
  to a yaml formatted file containing the run options.  All run options can be specified in this file
  except the Thor 'runtime options'.  You can tailor this file (e.g. path values) to match your local setup.
  Note: when no filename extension is used, will first try the filename as-is, and if it does not
  exsit, try the filename with a '.yml' extension.  If neither exists will generate an error.

  Additional information: '#{basename} --overview' or '#{basename} --examples'
DOC_RUN_OPTIONS
              doc_run_options.chomp
            end

          end
        end

        def doc_options
          say doc_overview, :green   if options[:overview]
          say doc_examples, :yellow  if options[:examples]
          stop_run if options[:overview] || options[:examples]
        end

        # *** Documentation files must use the sprintf substitution format of %{replace} (e.g. not #{replace}). ***

        def doc_examples
          file_path = File.expand_path("../../#{HELPERS_DIR}/doc/examples", __FILE__)
          doc_content(file_path)
        end

        def doc_overview
          file_path = File.expand_path("../../#{HELPERS_DIR}/doc/overview", __FILE__)
          doc_content(file_path)
        end

        def doc_content(file_path)
          return 'No documentation available.'  unless File.exist?(file_path)

          basename      = self.class.send(:basename)         # Binary run name e.g. totem-app
          framework     = (basename.split('-').shift) || ''  # Framework name from binary name e.g. totem
          cli           = framework + '-cli'                 # cli gem for this framework e.g. totem-cli
          example_app   = 'orchid'                           # example Rail app name
          rails_version = '>= 4.2.0'                         # Rails version required

          content_sub                 = Hash.new  # string substitutions e.g. %{name}
          content_sub[:basename]      = basename
          content_sub[:Basename]      = basename.capitalize
          content_sub[:framework]     = framework
          content_sub[:Framework]     = framework.capitalize
          content_sub[:cli]           = cli
          content_sub[:Cli]           = cli.capitalize
          content_sub[:example_app]   = example_app
          content_sub[:rails_version] = rails_version
          content_sub[:run_modes]     = doc_run_modes % content_sub  # common run modes text

          File.read(file_path) % content_sub
        end

        def doc_run_modes
          run_modes = <<DOC_RUN_MODES
'%{basename}' can be run in two modes (assumes a local copy of %{cli}):
  1. Run without installing the %{cli} gem.
     - advantages:    do no need to install the gem
     - disadvantages: need to use the relative path to the installer: relatvie_path/%{cli}/bin/%{basename}
  2. Run with installing the %{cli} gem.
     - advantages:    %{cli} gem includes a binary, so once installed just use: %{basename}
     - disadvantages: need to install the gem; if change the %{basename} gem itself, need to re-install
DOC_RUN_MODES
          run_modes.chomp
        end

      end
    end
  end
end
