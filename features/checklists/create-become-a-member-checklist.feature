Feature:  Create a user checklist based on a Master List
#
#When a user registers with the site,
#the 'become a member' checklist should be created for the user
#so the user knows what steps need to be compeled to become a member.
#
#
#  Background:
#
#    Given the following users exist:
#      | email                   | admin | member | first_name | last_name |
#      | applicant@happymutts.se |       |        | Kicki      | Applicant |
#      | admin@shf.se            | yes   |        |            |           |
#
#
#    Given the following Master Checklist exist:
#      | name                          | displayed_text                | list position | parent name     |
#      | Become a Member               | Become a Member               |               |                 |
#      | Complete the Application      | Complete the Application      | 0             | Become a Member |
#      | Provide supporting documents  | Provide supporting documents  | 1             | Become a Member |
#      | SHF approves your application | SHF approves your application | 2             | Become a Member |
#      | Agree to SHF Guidelines       | Agree to SHF Guidelines       | 3             | Become a Member |
#      | Pay Your Membership Fee       | Pay Your Membership Fee       | 4             | Become a Member |
#
#    Given the following regions exist:
#      | name      |
#      | Stockholm |
#
#    Given the following companies exist:
#      | name        | company_number | email               | region    |
#      | Happy Mutts | 5560360793     | hello@happymutts.se | Stockholm |
#
#    Given the following business categories exist
#      | name     | description                     |
#      | grooming | grooming dogs from head to tail |
#
#    And the application file upload options exist
#
#    And the following applications exist:
#      | user_email              | company_number | categories | state        |
#      | applicant@happymutts.se | 5560360793     | grooming   | under_review |
#
#
# # ------------------------------------------------------------------------
#
#  Scenario: Become a member checklist is created for an applicant when they register as a user
#    Given I am on the "login" page
#    And I click on t("devise.registrations.new.create_account")
#    Then I should be on the "register as a new user" page
#    When I fill in t("activerecord.attributes.user.first_name") with "Ima"
#    And I fill in t("activerecord.attributes.user.last_name") with "NewUser"
#    And I fill in t("activerecord.attributes.user.email") with "new-user@random.com"
#    And I fill in t("activerecord.attributes.user.password") with "password"
#    And I fill in t("users.registrations.new.confirm_password") with "password"
#    And I click on t("users.registrations.new.submit_button_label")
#    Then I should see t("users.registrations.new.success")
#
#    When I am logged in as "new-user@random.com"
#    And I am on the "my checklists" page
#    Then I should see the checklist "Become a Member" in the list of user checklists
#    And I should see the checklist "Complete the Application" in the list of user checklists
#    And I should see the checklist "Provide supporting documents" in the list of user checklists
#    And I should see the checklist "SHF approves your application" in the list of user checklists
#    And I should see the checklist "Agree to SHF Guidelines" in the list of user checklists
#    And I should see the checklist "Pay Your Membership Fee" in the list of user checklists
#    And I should not see the checklist "SHF Member Guidelines" in the list of user checklists
