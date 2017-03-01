namespace :thinkspace do
  namespace :common do
    namespace :users do

      task :downcase_email, [] => [:environment] do |t, args|
        Thinkspace::Common::User.all.each_with_index do |user, index|
          email      = user.email.downcase
          puts "[users] [#{index}] Converting email from [#{user.email}] to [#{email}]"
          user.email = email
          user.save
        end
      end

      task :update_roles, [] => [:environment] do |t, args|
        Thinkspace::Common::User.all.each do |user|
          is_teacher             = user.thinkspace_common_space_users.where(role: ['owner', 'update']).present?
          user.profile           = Hash.new unless user.profile.present?
          roles                  = user.profile['roles']
          roles                  = Hash.new unless roles.present?
          roles['instructor']    = is_teacher
          roles['student']       = !is_teacher
          user.profile['roles'] = roles
          user.save
        end
      end

    end
  end
end