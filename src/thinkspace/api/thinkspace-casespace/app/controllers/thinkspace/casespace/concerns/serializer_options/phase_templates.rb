module Thinkspace; module Casespace; module Concerns; module SerializerOptions; module PhaseTemplates

  def show(serializer_options)
    serializer_options.remove_all
  end

  def select(serializer_options); show(serializer_options); end

end; end; end; end; end
