require 'csv'
require 'open-uri'

namespace :thinkspace do
  namespace :importer do
    task :import_from_csv, [:file_path] => [:environment] do |t, args|
      puts "[ERROR] import_from_csv needs updated since removal of UserInvitation."
      return 
      file_path            = 'https://s3.amazonaws.com/thinkspace_addons/user_invitations.csv'
      file                 = Thinkspace::Importer::File.new
      file.custom_url      = file_path
      file.settings        = {
        headers:    { valid:    ['settings:send_to'], required: ['settings:role', 'settings:send_to'] },
        attributes: { application_id: 5000 },
        nested_attributes: {
          settings: { 
            space_id: 2,
            handler_class: 'Thinkspace::Casespace::InvitationHandler',
            handler_method: 'add_user_to_space',
            email: {
              subject: '[ThinkSpace] Importer Invitation Test'
            }
          }
        }
        #after_save: ['send_invitation']
      }
      file.generated_model = 'Thinkspace::Common::UserInvitation'
      file.process if file.save
    end


  end
end