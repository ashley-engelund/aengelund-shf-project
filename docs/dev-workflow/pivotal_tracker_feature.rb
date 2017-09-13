require 'aasm'

# This is the state machine that represents how we use PivotalTracker.
# You can use the 'aasm_statecharts' gem to create a diagram from it.

# The weedySeaDragon's (Ashley Engelund's) version of 'aasm_statecharts'
# was used to generate the .png diagram for this.  Use the following command:
#
#   bundle exec aasm_statecharts --include ./docs/dev-workflow pivotal_tracker_feature --table --directory ./docs/dev-workflow --config ./docs/dev-workflow/aasm-diagram-blue-green.yml
#
# where:
#  '--include ./app/models'  means "include path" ./app/models
#  'pivotal_tracker_feature'
#  '--table'  means "include a table in the diagraph generated"
#  '--directory ./docs/dev-workflow'  means "output to the directory " ./docs/dev-workflow
#  '--config ./docs/dev-workflow/aasm-diagram-blue-green.yml' means use the configuration file ./docs/dev-workflow/aasm-diagram-blue-green.yml
#
# The weedySeaDragon version of `aasm_statecharts` is in the Gemfile.
#


class PivotalTrackerFeature

  include AASM

  aasm do

    state :picked_upcoming_release_from_icebox, initial: true

    state :discussed

    state :points_assigned

    state :started, enter: :write_feature_or_spec, exit: :all_tests_pass
    
    state :finished_waiting_for_scrum_review, exit: :explained_and_demoed_in_scrum_meeting

    state :deployed_to_heroku_and_waiting_for_client_review, enter: :press_Finish_button_in_meeting

    state :client_accepted, enter: :press_Accepted_button_in_meeting

    state :client_rejected, enter: :press_Rejected_button_in_meeting

    state :deployed_to_production, enter: :press_Delivered_button, final: true


    event :discuss_task do
      transitions from: :picked_upcoming_release_from_icebox, to: :discussed
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
      transitions from: :started, to: :finished_waiting_for_scrum_review
    end


    event :approved_in_scrum_meeting do
      transitions from: :finished_waiting_for_scrum_review, to: :deployed_to_heroku_and_waiting_for_client_review, guard: :is_client_facing
      transitions from: :finished_waiting_for_scrum_review, to: :deployed_to_production, guard: :is_not_client_facing
    end

    event :shf_team_says_not_finished do
      transitions from: :finished_waiting_for_scrum_review, to: :started
    end


    event :client_accepts do
      transitions from: :deployed_to_heroku_and_waiting_for_client_review, to: :client_accepted, guard: :demo_on_heroku_passes
    end

    event :client_rejects do
      transitions from: :deployed_to_heroku_and_waiting_for_client_review, to: :client_rejected
    end




    event :deploy do
      transitions from: :client_accepted, to: :deployed_to_production
    end

  end




end
