require 'aasm'

# This is the state machine that represents how we use PivotalTracker.
# You can use the 'aasm_statecharts' gem to create a diagram from it.

# The weedySeaDragon's (Ashley Engelund's) version of 'aasm_statecharts'
# was used to generate the .png diagram for this.  Use the following command:
#  (Note that you should be in the Rails.root directory (e.g the directory
#   above /app.)
#
#   bundle exec aasm_statecharts --include ./docs/dev-workflow pivotal_tracker_feature --directory ./docs/dev-workflow --config ./docs/dev-workflow/aasm-diagram-blue-green.yml --table
#
# where:
#  '--include ./app/models'  means "include path" ./app/models
#  'pivotal_tracker_feature' is the model to be diagrammed (it's actually the name of the .rb file for the model)
#  '--directory ./docs/dev-workflow'  means "output to the directory " ./docs/dev-workflow
#  '--config aasm-diagram-blue-green.yml' means use the configuration file ./docs/dev-workflow/aasm-diagram-blue-green.yml
#  '--table'  means "include a table in the diagraph generated"
#
#
# The weedySeaDragon version of `aasm_statecharts` is in the Gemfile.
#


class PivotalTrackerFeature

  include AASM

  aasm do

    state :picked_a_story_from_an_upcoming_release, enter: :start_work_on_story,
          initial: true

    state :discussed

    state :points_assigned

    state :started, enter: :write_feature_or_spec, exit: :all_tests_pass
    
    state :finished_scrum_review, enter: :explained_and_demoed_in_scrum_meeting,
          exit: :team_approves

    state :deployed_to_heroku_and_waiting_for_client_review,
          enter: [:click_finish_and_deliver_buttons_in_meeting, :development_branch_changes_merged_to_heroku]

    state :deployed_to_heroku, enter: :development_branch_changes_merged_to_heroku

    state :client_accepted, enter: :press_Accepted_button_in_meeting

    state :client_rejected, enter: :press_Rejected_button_in_meeting

    state :deployed_to_production, enter: :merge_changes_from_Heroku_to_DigitalOcean,
          final: true


    event :discuss_task do
      transitions from: :picked_a_story_from_an_upcoming_release, to: :discussed
      transitions from: :client_rejected, to: :discussed
    end

    event :vote_on_feature do
      transitions from: :discussed, to: :points_assigned, guard: :at_least_3_people_voted
    end

    event :start_work do
      transitions from: :points_assigned, to: :started, guard: :is_client_facing
      transitions from: :discussed, to: :started, guard: :is_not_client_facing
    end

    event :finished_PR do
      transitions from: :started, to: :finished_scrum_review
    end


    event :approved_in_scrum_meeting do
      transitions from: :finished_scrum_review, to: :deployed_to_heroku_and_waiting_for_client_review, guard: :is_client_facing
      transitions from: :finished_scrum_review, to: :deployed_to_heroku, guard: :is_not_client_facing
    end

    event :shf_team_says_not_finished do
      transitions from: :finished_scrum_review, to: :started
    end


    event :client_accepts do
      transitions from: :deployed_to_heroku_and_waiting_for_client_review, to: :client_accepted, guard: :demo_on_heroku_passes
    end

    event :client_rejects do
      transitions from: :deployed_to_heroku_and_waiting_for_client_review, to: :client_rejected
    end




    event :deploy do
      transitions from: :client_accepted, to: :deployed_to_production
      transitions from: :deployed_to_heroku, to: :deployed_to_production
    end

  end




end
