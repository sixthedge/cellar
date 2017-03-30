require_relative '../../../../thinkspace-casespace/test/helpers/controller_helper'
require_relative '../../../../thinkspace-casespace/test/phase_actions/helpers/phase_actions_helper'

require_test_helper_files('../readiness_assurance/helpers/route', engine: 'thinkspace-readiness-assurance')
require_test_helper_files('../readiness_assurance/helpers', engine: 'thinkspace-readiness-assurance')
Test::Casespace::Seed.load(config: :readiness_assurance)
