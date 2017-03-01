namespace :thinkspace do
  namespace :common do
    namespace :spaces do
      task :ensure_space_types, [] => [:environment] do |t, args|
        space_type_id = ENV['SPACE_TYPE_ID']
        unless space_type_id.present?
          puts "[ensure_space_types] ERROR: No space type id found."
          return
        end
        space_type = Thinkspace::Common::SpaceType.find_by(id: space_type_id)
        unless space_type.present?
          puts "[ensure_space_types] ERROR: No space type found for id [#{space_type_id}]."
          return
        end
        Thinkspace::Common::Space.all.each do |space|
          space_types = space.thinkspace_common_space_types
          unless space_types.present?
            puts "[ensure_space_types] Updating Space [#{space.id}] with space type [#{space_type.id}]"
            space.thinkspace_common_space_types << space_type
          end
        end
      end
    end
  end
end