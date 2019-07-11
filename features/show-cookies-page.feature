Feature: Show the Cookies page

  As a visitor
  So that I understand what cookies are used by this site
  Show me the cookies page

  PT:  https://www.pivotaltracker.com/story/show/165031450

  Background:
    Given the following users exists
      | email                 | admin | membership_number | member |
      | applicant@example.com |       |                   |        |
      | member@example.com    |       | 101               | true   |
      | admin@shf.se          | true  |                   |        |

    And the following regions exist:
      | name      |
      | Stockholm |

    And the following companies exist:
      | name        | company_number | email               | region    |
      | Happy Mutts | 5560360793     | woof@happymutts.com | Stockholm |
      | Bowsers     | 2120000142     | bark@bowsers.com    | Stockholm |

    And the following applications exist:
      | user_email            | contact_email         | company_number | state    |
      | member@example.com    | member@happymutts.com | 5560360793     | accepted |
      | applicant@example.com | applicant@bowsers.com | 2120000142     | new      |


  Scenario: show visitor the cookies page
    Given I am Logged out
    And I am on the "cookies" page
    Then I should see "Kakor (cookies)"


  Scenario: show a User the cookies page
    Given I am logged in as "applicant@example.com"
    And I am on the "cookies" page
    Then I should see "Kakor (cookies)"


  Scenario: show a Member the cookies page
    Given I am logged in as "member@example.com"
    And I am on the "cookies" page
    Then I should see "Kakor (cookies)"


  Scenario: show an Admin the cookies page
    Given I am logged in as "admin@shf.se"
    And I am on the "cookies" page
    Then I should see "Kakor (cookies)"
