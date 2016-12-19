Feature: As an admin
  In order to keep business categories correct and helpful to visitors and members
  I need to be able to delete any that aren't needed or valid

  PT:


  Background:
    Given the following users exists
      | email                  | is_member |
      | applicant_1@random.com | false     |
      | applicant_2@random.com | false     |
      | applicant_3@random.com | true      |

    And the following applications exist:
      | first_name | user_email             | company_number | status  |
      | Emma       | applicant_1@random.com | 5560360793     | pending |
      | Hans       | applicant_2@random.com | 2120000142     | pending |
      | Nils       | applicant_3@random.com | 2120000142     | Godkänd |


  Scenario: Admin wants to delete an existing membership application
    Given I am logged in as "admin@shf.com"
    And I am on "Emma" application page
    And I click on t("membership_application.edit.delete") button
    Then I should see " raderad"
    And I should not see "Emma"
    And I should see "2" applications



