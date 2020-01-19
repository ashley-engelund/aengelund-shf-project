Feature: User or Member checks or unchecks a user checklist item as completed

  As a user or member,
  When I complete an item on one of my checklists,
  I need to be able to manually check is as completed (or uncheck it)
  So that SHF knows of my progress


  Background:

    Given the following users exist:
      | email                | admin | member | first_name | last_name |
      | applicant@random.com |       |        | Kicki      | Applicant |
      | member@random.com    |       | true   | Lars       | Member    |
      | admin@shf.se         | yes   |        |            |           |


    Given the following Master Checklist exist:
      | name                          | displayed_text                               | list position | parent name           |
      | Become a Member               | Become a Member                              |               |                       |
      | Complete the Application      | Complete the Application                     | 0             | Become a Member       |
      | Provide supporting documents  | Provide supporting documents                 | 1             | Become a Member       |
      | SHF approves your application | SHF approves your application                | 2             | Become a Member       |
      | Agree to SHF Guidelines       | Agree to SHF Guidelines                      | 3             | Become a Member       |
      | Pay Your Membership Fee       | Pay Your Membership Fee                      | 4             | Become a Member       |
      | SHF Member Guidelines         | SHF Membership Guidelines                    |               |                       |
      | Section 1                     | Guideline section 1                          | 0             | SHF Member Guidelines |
      | Guideline 1.1                 | text displayed to the user for Guideline 1.1 | 0             | Section 1             |
      | Guideline 1.2                 | text displayed to the user for Guideline 1.2 | 1             | Section 1             |
      | Guideline 1.3                 | text displayed to the user for Guideline 1.3 | 2             | Section 1             |
      | Section 2                     | Guideline section 2                          | 1             | SHF Member Guidelines |
      | Guideline 2.1                 | text displayed to the user for Guideline 2.1 | 0             | Section 2             |


    Given the following user checklists exist:
      | user email           | checklist name        |
      | applicant@random.com | Become a Member       |
      | member@random.com    | SHF Member Guidelines |

    Given the following user checklist items have been completed:
      | user email           | checklist name           | date completed |
      | applicant@random.com | Complete the Application | 2019-12-12     |
      | member@random.com    | Guideline 1.2            | 2020-02-02     |
      | member@random.com    | Guideline 1.3            | 2020-03-03     |


  @time_adjust @selenium
  Scenario: User checks a checklist item as completed and the date completed is shown
    Given I am logged in as "applicant@random.com"
    And the date is set to "2019-12-20"
    And I am on the "my checklists" page
    Then I should see the date completed as 2019-12-12 for the user checklist "Complete the Application"

    When I check the checkbox for the user checklist "Provide supporting documents"
    Then I should see the date completed as 2019-12-20 for the user checklist "Provide supporting documents"
    And the checkbox for the user checklist "Provide supporting documents" should be checked


  @selenium
  Scenario: User unchecks a checklist item as completed and the date completed is hidden
    Given I am logged in as "applicant@random.com"
    And I am on the "my checklists" page
    Then I should see the date completed as 2019-12-12 for the user checklist "Complete the Application"

    When I uncheck the checkbox for the user checklist "Complete the Application"
    Then the checkbox for the user checklist "Complete the Application" should not be checked
    And I should not see a date completed for the user checklist "Complete the Application"


  @selenium
  Scenario: A checklist with children cannot be checked as completed. It should be disabled
    Given I am logged in as "member@random.com"
    And I am on the "my checklists" page

    Then I should not see a date completed for the user checklist "Guideline section 1"
    And I should not see a date completed for the user checklist "text displayed to the user for Guideline 1.1"
    And I should see the date completed as 2020-02-02 for the user checklist "text displayed to the user for Guideline 1.2"
    And I should see the date completed as 2020-03-03 for the user checklist "text displayed to the user for Guideline 1.3"
    And the checkbox for the user checklist "Guideline section 1" should be disabled


  @time_adjust @selenium
  Scenario: The last sub-item is checked complete and the parent list checkbox is automatically checked and also shows the date completed
    Given I am logged in as "member@random.com"
    And the date is set to "2020-06-06"
    And I am on the "my checklists" page
    Then I should not see a date completed for the user checklist "Guideline section 1"
    And I should not see a date completed for the user checklist "text displayed to the user for Guideline 1.1"
    Then I should see a date completed for the user checklist "text displayed to the user for Guideline 1.2"
    And I should see the date completed as 2020-02-02 for the user checklist "text displayed to the user for Guideline 1.2"
    And I should see the date completed as 2020-03-03 for the user checklist "text displayed to the user for Guideline 1.3"

    When I check the checkbox for the user checklist "text displayed to the user for Guideline 1.1"
    Then the checkbox for the user checklist "text displayed to the user for Guideline 1.1" should be checked
    And I should see the date completed as 2020-06-06 for the user checklist "text displayed to the user for Guideline 1.1"
    And I should see the date completed as 2020-06-06 for the user checklist "Guideline section 1"
    And the checkbox for the user checklist "Guideline section 1" should be checked

    # These are not changed
    And I should see the date completed as 2020-02-02 for the user checklist "text displayed to the user for Guideline 1.2"
    And I should see the date completed as 2020-03-03 for the user checklist "text displayed to the user for Guideline 1.3"
