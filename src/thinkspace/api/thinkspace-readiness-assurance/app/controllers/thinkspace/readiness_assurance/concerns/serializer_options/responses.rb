module Thinkspace; module ReadinessAssurance; module Concerns; module SerializerOptions; module Responses

  def show(serializer_options)
    common_serializer_options(serializer_options)
  end

  def update(serializer_options)
    common_serializer_options(serializer_options)
    serializer_options.remove_all
    serializer_options.only_attributes :id, :answers, :justifications, :userdata
  end

  def common_serializer_options(serializer_options)
    serializer_options.remove_association  :ownerable
    serializer_options.remove_association  :thinkspace_common_user
  end

end; end; end; end; end
