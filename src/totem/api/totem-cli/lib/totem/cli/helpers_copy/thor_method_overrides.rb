module Totem; module Cli; module HelpersCopy; module ThorMethodOverrides

  # Override the 'copy_file' Thor actions to allow changing
  # the destination path argument to alter the destination path.
  # After altering the destination path, call the original method with the arguments.
  ::Thor::Actions.class_eval do
    alias_method :original_copy_file, :copy_file
    def copy_file(source, *args, &block)
      path    = self.send(:totem_destination_path, args[0])
      args[0] = path
      original_copy_file(source, *args, &block)
    end
  end

end; end; end; end
