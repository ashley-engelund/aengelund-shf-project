Feature: As a non-swedish speaking potential member
  In order to understand the information
  the site must also offer at least English.

  This also makes tests less brittle because the wording will be able to
  change without affecting any code. (It will just change in the
  locale .yml files.)

  PT: https://www.pivotaltracker.com/story/show/133316647

  Background:
    Given the following users exists
      | email                | password | admin | is_member |
      | emma@random.com      | password | false | false     |


  Scenario: Devise New password view is translated
    Given I am on the "new password" page
    Then I should see t("activerecord.attributes.user.email")
    And I should see t("forgot_password")
    And I should see button t("send_reset_instructions")

  Scenario: Devise New registration view is translated
    Given I am on the "register a new user" page
    Then I should see t("activerecord.attributes.user.password")
    And I should see t("activerecord.attributes.user.password")
    And I should see t("activerecord.attributes.user.password")
    And I should see t("confirm_password")

  Scenario: Devise Edit registration view is translated
    Given I am logged in as "emma@random.com"
    And I am on the "edit registration for a user" page
    Then I should see t("activerecord.attributes.user.password")
    And I should see t("activerecord.attributes.user.password")
    And I should see t("confirm_password")
    And I should see t("current_password")
    And I should see t("leave_blank_if_no_change")
    And I should see t("required_to_save_changes")
    And I should see t("unregister")
    And I should see button t("delete_my_account")




