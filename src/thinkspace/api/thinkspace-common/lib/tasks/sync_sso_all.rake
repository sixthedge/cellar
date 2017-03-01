namespace :thinkspace do
  namespace :users do
    task :sync_sso_all, [] => [:environment] do |t, args|

      Thinkspace::Common::User.all.each do |u|
        u.sync_sso
      end
    end
  end
end