Feature: User is automatically logged out after timeout time exceeded

  As a user, if I have been inactive more than the timeout time configured,
  I am automatically logged out
  So that the system does not have lots of open, inactive sessions in use


  Background:
    Given the following users exists
      | email                | password | admin | member |
      | emma@random.com      | password | false | true   |
      | lars-user@random.com | password | false | false  |
      | anne@random.com      | password | false | false  |
      | arne@random.com      | password | true  | true   |

    And the following applications exist:
      | user_email           | company_number | state        |
      | emma@random.com      | 5562252998     | accepted     |
      | lars-user@random.com | 2120000142     | under_review |


  # assumes the timeout time is configured to < 3 hours
  @time_adjust
  Scenario: I am logged out because I have been inactive longer than the timeout time
    Given the date is set to "2019-05-01"
    And I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "emma@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And time advances by 3 "hours"
    And I am on the "user profile" page for "emma@random.com"
    Then I should see t("devise.failure.timeout")


  # assumes the timeout time is configured to 1 hour or more
  @time_adjust
  Scenario: I am not loggged out when I do something before the timeout time
    Given the date is set to "2019-05-01"
    And I am on the "login" page
    When I fill in t("activerecord.attributes.user.email") with "emma@random.com"
    And I fill in t("activerecord.attributes.user.password") with "password"
    And I click on t("devise.sessions.new.log_in") button
    Then I should see t("devise.sessions.signed_in")
    And time advances by 59 "minutes"
    And I am on the "user profile" page for "emma@random.com"
    Then I should not see t("devise.failure.timeout")
