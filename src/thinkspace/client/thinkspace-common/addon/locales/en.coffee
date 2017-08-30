export default {

  thinkspace:
    branding:         "Think<span class='ts-branding_space'>Space</span>"
    branding_short:   "T<span class='ts-branding_space'>S</span>"

  builder:

    selector:
      headings:
        new_case:        'New Case'
        casespace_type:  'Case'
        assessment_type: 'Peer Asessment'
      ask:
        case_type: 'What type of case did you want to create?'
      describe:
        casespace:       'Cases are a great way to present authentic real-world problems and situations for your students to solve.'
        peer_assessment: 'Peer assessment is at the heart of keeping students accountable to their teammates for their preparation and contribution to team activities.'
      instruct:
        team_set_required: 'You must have a Team Set before creating a peer assessment.'
      buttons:
        cancel: 'Cancel'

    assessment:
      headings:
        new_assessment:    'New Peer Assessment'
        settings:          'Peer Assessment Settings'
        method_michaelsen: 'Michaelsen method'
        method_custom:     'My own method'
        team_set:          'Team Set'
        case_confirmation: 'Case Confirmation'
        case_details:      'Case Details'
        case_name:         'Case Name'
        case_settings:     'Case Settings'
        case_instructions: 'Case Instructions'
        case_logistics:    'Case Logistics'
        due_date:          'Due Date'
        release_date:      'Release Date'
      describe:
        details:           "Lets start with some basic information and go from there."
        settings:          "Now we're getting into the nitty-gritty."
        method_michaelsen: "The Michaelsen method balances an avarage of 10 points per team member and asks students to give a positive and constructive comment for each member of their team."
        method_custom:     'Make your own peer assessment method by choosing whether you want categories, point balancing, or just free scoring. '
        no_team_sets:      "Looks like you haven't made any team sets. You will need to create one before creating an assessment."
        confirmation:      "Check and make sure everything looks correct. This is the last time you'll get to change the assessment. "
      instruct:
        name_case:    'Name your case'
        method:       'Which peer assessment method do you want to use?'
        set_team_set: 'Choose a team set for this assessment.'
      validations:
        place: 'holder'
      buttons:
        back:   'Back'
        next:   'Next Step'
        edit:   'Edit'
        create: 'Finish Assessment'
      loaders:
        place: 'holder'

    casespace:
      headings:
        edit_dates:        'Edit Dates'
        date_logistics:    'Date Logistics'
        edit_instructions: 'Edit Instructions'
        edit_phases:       'Edit Phases'
        case_name:         'Case Name'
        edit_details:      'Edit Details'
        case_details:      'Case Details'
        case_confirmation: 'Case Confirmation'
        state:             'State'
        due_date:          'Due Date'
        release_date:      'Release Date'
        case_instructions: 'Case Instructions'
        case_logistics:    'Case Logistics'
        order_phases:      'Order Phases'
        new_phase:         'New Phase'
        case_templates:    'Case Templates'
        new_case:          'New Case'
        edit_case:         'Edit Case'
        clone_case:        'Clone into Space'
      describe:
        details:      "Let's start with some basic information and go from there."
        phases:       'Manage the phases of your case here.'
        logistics:    "Let's set up the logistics of the case."
        states:       'If the case is inactive, it will never be seen by students regardless of the release date.'
        confirmation: 'Review the case information and make sure it is correct before you %@ it.'
      instruct:
        case_name:        'Name your case'
        choose_template:  'Choose a template to start off with.  You can edit the phases in the next section.'
        work_on_phases:   'Time to work on the actual phases fo the case.'
        add_instructions: 'Give the students some general instructions for this case.'
        set_release_date: 'Set the day and time the case will be available to your students.'
        set_due_date:     'Set the last date and time this case will be available to your students.'
      validations:
        required_template: 'You must select a case template to continue.'
      buttons:
        back:   'Back'
        next:   'Next Step'
        save:   'Save Case'
        create: 'Finish Case'
        exit:   'Exit'
      loaders:
        case_templates: 'Loading case templates...'
        componentables: 'Loading components...'
      phases:
        edit:
          headings:
            general_information: 'General Information'
            submit_events:       'Phase Submit Events'
            submission:          'Submission'
            main_title:          'Phase Settings - %@'
            details:             'Details (required)'
            title:               'Title'
            max_score:           'Max Score'
            team_based:          'Team-Based Learning'
            components:          'Components'
            no_componentables:   'No editable components are on this phase.'
          properties:
            title:         'Title'
            description:   'Description'
            team_category: 'Team Category'
            team_set:      'Team Set'
          describe:
            edit:                   'Change settings of the phase from submission events to teams.'
            details:                'Manage the required settings of this phase'
            submission:             'Manage the submission process for a phase'
            submit_visible:         'When enabled, the submit button will be displayed at the bottom of a phase.  Required for any phase submission events.'
            submit_text:            'Change this if you like to have the submit button say something other than "submit"'
            configuration_validate: 'Require all text inputs to be filled out before the student can submit the phase.  Presently, this setting only affects inputs in the HTML component.'
            submit_events:          'Control the phase behavior when a student submits their phase'
            complete_phase:         'This phase will show up as completed as soon as the student submits their responses.  The phase will no longer be editable when completed.'
            unlock_phase:           'The next phase will automatically unlock and be available to the student when this phase is completed.'
            auto_score:             'When the phase is submitted, ThinkSpace will automatically award full points to the student.'
            team_based:             'Manage which team set is assigned to this phase and how the teams interact with the phase'
            team_category:          'All teams in the team set will interact with the phase based on the selection here.'
          instruct:
            submit_visible:         'Enable submit button'
            submit_text:            'Change submit button text'
            configuration_validate: 'Enable input validation'
            complete_phase:         'Mark phase as complete'
            unlock_phase:           'Unlock next phase on submission'
            auto_score:             'Phase auto scoring'
            team_based:             'Enable team based'
            team_category:          'What type of team-based case'
            team_set:               'Selected team set'
          buttons:
            cancel: 'Cancel'
            save:   'Update Settings'
      mode:
        edit:   'Edit Mode'
        clone:  'Clone Mode'
        delete: 'Delete Mode'

    lab:
      category:
        heading:
          result_name: 'Test Name'
          description: 'Description'
          result:      'Test Result'
          units:       'Units'
          range:       'Range'
          analysis:    'Analysis'
          abnormality: 'Abnormality Name'
        correctable_prompt:  'Should this be corrected?'

      admin:
        link:                 'Edit'
        new_category:         'New Category'
        edit_category:        'Edit Category'
        delete_category:      'Delete Category'
        new_result:           'New Result'
        new_adjusted_result:  'New Adjusted Result'
        new_html_result:      'New Information Result'
        edit_result:          'Edit Result'
        edit_adjusted_result: 'Edit Adjusted Result'
        edit_html_result:     'Edit Information Result'
        form:
          buttons:
            edit:   'Edit'
            clone:  'Clone'
            delete: 'Delete'
          title:              'Title'
          correctable_prompt: 'Correctable Prompt'
          column_headings:    'Column Headings'
          description:        'Description'
          result_heading:
            html_result:     'Information'
            adjusted_result: 'Adjusted'
          abnormality:
            correct_values: 'Correct Values'
            max_attempts:   'Max Attempts'
            errors:
              max_attempts: 'Max attempts must be a number'
          analysis:
            selections: 'Selections'
            normal:     'Normal'
            correct:    'Correct'
            errors:
              selections_blank:       'All selections are blank'
              duplicate_label:        '"%@" is a duplicate'
              normal_blank:           'Normal cannot be blank'
              normal_not_selectable:  'Normal: "%@" is not a selectable option'
              correct_blank:          'Correct cannot be blank'
              correct_not_selectable: 'Correct: "%@" is not a selectable option'
          correctable:
            correct_value: 'Correct Value'
            max_attempts:  'Max Attempts'
            errors:
              max_attempts: 'Max attempts must be a number'
          range:
            lower: 'Lower'
            upper: 'Upper'
        buttons:
          add:    'Add'
          cancel: 'Cancel'
          save:   'Save'
          no:     'No'
          yes:    'Yes'
        category:
          destroy_prompt: 'Do you really want to delete the following Category?'
        result:
          heading:
            html_result:     'Information'
            adjusted_result: 'Adjusted'
          destroy_prompt: 'Do you really want to delete the following Result?'
          form_errors:    'The form has errors.  Please correct and re-save.'

  casespace:
    space:      'Space'
    assignment: 'Case'
    phase:      'Phase'
    phases:     'Phases'

    api:

      success:

        thinkspace:

          artifact:
            bucket:
              save: 'Bucket saved successfully.'
            file:
              save: 'File saved successfully.'
              destroy: 'File removed successfully.'
          casespace:
            assignment:
              save: 'Case saved successfully.'
              submit: 'Case submitted successfully.'
              clone: 'Case cloned successfully.'
              delete: 'Case deleted successfully.'
            phase:
              save: 'Phase saved successfully.'
              submit: 'Phase submitted successfully.'
              clone: 'Phase cloned successfully.'
              destroy: 'Phase deleted successfully.'
            phase_score:
              save: 'Phase score saved successfully.'
            phase_state:
              save: 'Phase state saved successfully.'
          common:
            invitation:
              save: 'Invitation sent successfully.'
              resend: 'Invitation resent successfully.'
              destroy: 'Invitation removed successfully.'
            space:
              save: 'Space saved successfully.'
              clone: 'Started cloning the space, you will be notified via email when it is complete.'
            space_user:
              save: 'Space user saved successfully.'
          diagnostic_path:
            path:
              save: 'Diagnostic path saved successfully.'
            path_item:
              save: 'Diagnostic path saved successfully.'
              destroy: 'Diagnostic path removed successfully.'
          html:
            content:
              save: 'HTML content saved successfully.'
          input_element:
            response:
              save: 'Response saved successfully.'
          lab:
            observation:
              save: 'Observation saved successfully.'
            result:
              save: 'Result saved successfully.'
          markup:
            comment:
              save: 'Comment saved successfully.'
          observation_list:
            list:
              save: 'Observation list saved successfully.'
            observation:
              save: 'Observation saved successfully.'
              destroy: 'Observation removed successfully.'
            observation_note:
              save: 'Observation note saved successfully.'
              destroy: 'Observation note removed successfully.'
          resource:
            file:
              save: 'File saved successfully.'
              destroy: 'File removed successfully.'
            link:
              save: 'Link saved successfully.'
              destroy: 'Link removed successfully.'
            tag:
              save: 'Tag saved successfully.'
              destroy: 'Tag removed successfully.'
          peer_assessment:
            assessment:
              approve: 'Results sent successfully.'
              approve_team_sets: 'All teams approved successfully'
            review:
              save: 'Evaluation saved successfully.'
            review_set:
              save: 'Evaluations saved successfully.'
              ignore: 'Evaluations ignored successfully.'
              unignore: 'Evaluations unignored successfully.'
              unlock: 'Evaluations unlocked successfully. The student will be notified.'
              complete: 'Evaluations have been successfully submitted.'
              remind: 'Reminder email sent successfully.'
          readiness_assurance:
            assessment:
              save: 'Readiness assurance assessment saved successfully.'
              submit: 'Peer evaluation submitted successfully.'
            team_set:
              approve: 'Team evaluations approved successfully.'
              unapprove: 'Team evaluations unapproved successfully.'
          team:
            team:
              save: 'Team saved successfully.'
              destroy: 'Team removed successfully.'
            team_set:
              save: 'Team set saved successfully.'
              destroy: 'Team set removed successfully.'
              explode: 'Team changes saved successfully.'
              revert: 'Team changes reverted successfully.'
            team_user:
              save: 'Team member saved successfully.'
              destroy: 'Team member removed successfully.'
          weather_forecaster:
            forecast:
              save: 'Forecast saved successfully.'
            response:
              save: 'Response saved successfully.'

          stripe:
            customer:
              card_saved: 'Payment successful!'


    # spaces:
    #   one:   'Space ONE found'
    #   other: 'Spaces OTHER found'

}
