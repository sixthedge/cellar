require 'csv'

namespace :thinkspace do
  namespace :grades do
    task :csv_for_space, [:space_id, :file_name] => [:environment] do |t, args|
      space_id = args.space_id
      space    = Thinkspace::Common::Space.find(space_id)
      raise "No space found for space id #{space_id}" unless space
      raise "No file path provided" unless args.file_name
      space_users = space.thinkspace_common_space_users.where(role: 'read').includes(:thinkspace_common_user).order('thinkspace_common_users.last_name')
      assignments = space.thinkspace_casespace_assignments
      data        = []
      csv_headers = []
      csv_headers << 'Last Name'
      csv_headers << 'First Name'
      csv_headers << 'E-mail Address'

      assignments.each do |assignment|
        csv_headers << assignment.title
        phases      = assignment.thinkspace_casespace_phases
        
        phases.each do |phase|
          csv_headers << assignment.title + '-' + phase.title
        end
      end

      space_users.each do |space_user|
        space_user_data  = []
        user             = space_user.thinkspace_common_user
        space_user_data  << user.last_name
        space_user_data  << user.first_name
        space_user_data  << user.email
        assignments.each do |assignment|
          phases            = assignment.thinkspace_casespace_phases
          phase_ids         = phases.pluck(:id)
          phase_states      = Thinkspace::Casespace::PhaseState.where(phase_id: phase_ids, ownerable: user)
          user_phase_scores = Thinkspace::Casespace::PhaseScore.where(phase_state_id: phase_states.pluck(:id))
          phase_scores      = user_phase_scores.pluck(:score)
          assignment_score  = 0

          phase_scores.each { |ps| if ps then assignment_score += ps end }
          space_user_data   << assignment_score.to_s
          phases.each       do |phase|
            phase_state = phase_states.find_by(phase_id: phase.id, ownerable: user)
            if phase_state.present?
              phase_score = user_phase_scores.find_by(phase_state_id: phase_state.id)
              phase_score.present? ? score = phase_score.score.to_s : score = '0'
            else
              score = '0'
            end
            space_user_data  << score
          end
        end
        data.push(space_user_data)
      end
      CSV.open(args.file_name, 'wb') do |csv|
        csv << csv_headers

        data.each do |row_data|
          csv << row_data
        end
      end
      file = File.open(args.file_name)
      importer_file = Thinkspace::Importer::File.new
      importer_file.attachment = file
      importer_file.save
      puts importer_file.url
      File.delete(args.file_name)
    end
  end
end