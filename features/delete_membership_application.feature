Feature: As an admin
  In order to keep business categories correct and helpful to visitors and members
  I need to be able to delete any that aren't needed or valid

  PT:

  When a membership application is deleted, if it is the only application
  associated with a company, then delete the company too.

  Background:
    Given the following users exists
      | email            | admin |
      | emma@random.com  |       |
      | hans@bowsers.com |       |
      | nils@bowsers.com |       |
      | admin@shf.se     | true  |
      | wils@woof.com    |       |
      | bob@bowsers.com  |       |



    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |

    # old_region is currently required so that company_complete? is true
    And the following companies exist:
      | name        | company_number | email               | region       | old_region |
      | Happy Mutts | 2120000142     | woof@happymutts.com | Stockholm    | Sweden     |
      | Bowsers     | 5560360793     | bark@bowsers.com    | Stockholm    | Sweden     |
      | WOOF        | 5569467466     | woof@woof.com       | Västerbotten | Sweden     |


    And the following applications exist:
      | first_name | user_email       | company_number | state        |
      | Emma       | emma@random.com  | 5560360793     | under_review |
      | Hans       | hans@bowsers.com | 2120000142     | under_review |
      | Nils       | nils@bowsers.com | 2120000142     | accepted     |
      | Wils       | wils@woof.com    | 5569467466     | accepted     |


  Scenario: Admin should see the 'delete' button
    Given I am logged in as "admin@shf.se"
    And I am on the application page for "Emma"
    Then I should not see t("errors.not_permitted")
    And I should see t("membership_applications.show.delete")


  Scenario: Member should not see the 'delete' button on their own application
    Given I am logged in as "emma@random.com"
    And I am on the application page for "Emma"
    Then I should not see t("errors.not_permitted")
    And I should not see t("membership_applications.show.delete")

  Scenario: Visitor should not see the 'delete' button
    Given I am Logged out
    And I am on the application page for "Emma"
    Then I should see t("errors.not_permitted")
    And I should not see t("membership_applications.show.delete")


  Scenario: Admin wants to delete a membership application
    Given I am logged in as "admin@shf.se"
    And I am on the application page for "Emma"
    And I click on t("membership_applications.show.delete")
    Then I should see t("membership_applications.application_deleted")
    And I should not see "Emma"


  Scenario: Admin deletes a membership application; company should still exist (has another application assoc.)
    Given I am logged in as "admin@shf.se"
    And I am on the application page for "Hans"
    And I click on t("membership_applications.show.delete")
    Then I should see t("membership_applications.application_deleted")
    And I should not see "Hans"
    And I am on the "all companies" page
    And I should see "2120000142"

  @focus
  Scenario: Admin deletes the only membership application associated with a company. Company is deleted
    Given I am logged in as "admin@shf.se"
    And I am on the "all companies" page
    Then I should see "3" companies
    And I should see "WOOF"
    And I am on the application page for "Wils"
    And I click on t("membership_applications.show.delete")
    Then I should see t("membership_applications.application_deleted")
    And I should not see "Wils"
    When I am on the "all companies" page
    Then I should see "2" companies
    And I should not see "WOOF"
    
    