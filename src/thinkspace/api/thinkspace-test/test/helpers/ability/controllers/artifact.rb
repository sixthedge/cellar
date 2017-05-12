module Test; module Ability; module Controllers; module Thinkspace  module Artifact; module Api

  class FilesController
    def setup_create_can_update(route); setup_create_reader(route); end
    def setup_create_reader(route); route.assert_unauthorized(/invalid request for uploading/i); end
  end

end; end; end; end; end; end
