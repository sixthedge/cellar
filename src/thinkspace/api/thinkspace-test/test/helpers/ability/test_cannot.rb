module Test::Ability::TestCannot
  extend ActiveSupport::Concern
  included do

    @models.each do |model|
      @actions.each do |action|
        @users.each do |user|
          describe 'ability'  do
            it "..#{get_username(user)}..cannot..#{action}..#{model.title}.." do
              assert_cannot(user, model, action)
            end
          end
        end
      end
    end

  end # included

end
