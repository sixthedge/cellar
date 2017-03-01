require File.expand_path('../../support_helper', __FILE__)

module Test::Framework::ActiveModelSerializer; end
module Test::Framework::Authorize; end
module Test::Framework::Ability; end

def user;              path_to_class('test/platform/main/user'); end
def framework_ability; path_to_class('test/framework/cancan/ability'); end
def platform_ability;  path_to_class('test/platform/authorization/ability'); end

