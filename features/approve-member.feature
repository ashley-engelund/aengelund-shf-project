Feature: As an admin
  so that a new member gets notified that they have been approved and can then fill out their info,
  when I change their status to approved,
  send them email notifying them,
  and create their Company if it doesn't already exist,
  and associate them with the company

  PT: https://www.pivotaltracker.com/story/show/135472437

  Background:
    Given the following users exists
      | email                 | admin |
      | emma@happymutts.se    |       |
      | hans@happymutts.se    |       |
      | anna@nosnarkybarky.se |       |
      | admin@shf.com         | true  |

    Given the following business categories exist
      | name         | description                     |
      | dog grooming | grooming dogs from head to tail |
      | dog crooning | crooning to dogs                |
      | rehab        | physcial rehabitation           |


    Given the following companies exist:
      | name                 | company_number | email                 |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.se |


    And the following applications exist:
      | first_name | user_email            | company_number | status  | category_name |
      | Emma       | emma@happymutts.se    | 5562252998     | pending | Rehab         |
      | Hans       | hans@happymutts.se    | 5562252998     | pending | grooming      |
      | Anna       | anna@nosnarkybarky.se | 5560360793     | pending | Rehab         |

    And I am logged in as "admin@shf.com"

  Scenario: Admin approves, no company exists so one is created
    Given I am on "Emma" application page
    When I set "membership_application_status" to "Accepted"
    And I click on "Update"
    And I should be on the edit application page for "Emma"
    And I should see "Now please enter the new membership number and submit."
    And I should see "Membership number"
    And I fill in "Membership number" with "901"
    And I click on "Submit"
    Then I should see "Membership Application successfully updated"
    And I should see "Accepted"
    And I should see "901"
    And I am on the "all companies" page
    And I should see "5562252998"


  Scenario: Admin approves, member is added to existing company


  Scenario: Admin approves, enters new membership number

  Scenario: Admin approves, but then changes back to pending

