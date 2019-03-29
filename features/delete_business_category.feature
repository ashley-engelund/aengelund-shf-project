Feature: As an admin
  In order to keep business categories correct and helpful to visitors and members
  I need to be able to delete any that aren't needed or valid

  PT: https://www.pivotaltracker.com/story/show/135009339


  Background:
    Given the following users exists
      | email                | admin |
      | applicant@random.com |       |
      | admin@shf.com        | true  |

    And the following business categories exist
      | name           | description                     |
      | doggy grooming | grooming dogs from head to tail |
      | dog crooning   | crooning to dogs                |

  @selenium
  Scenario: Admin wants to delete an existing business category
    Given I am logged in as "admin@shf.com"
    And I am on the "business categories" page
    When I click and accept the icon with CSS class "delete" for the row with "doggy grooming"
    Then I should see t("business_categories.destroy.success")
    And I should not see "doggy grooming"



