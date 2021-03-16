Feature: Show User's Companies with accepted apps in the navigation menu

  Show all companies that a user has an accepted application for
  in the 'My Companies' navigation menu.
  The user does not have to be a member.

  As a user
  So that I can see the detailed information about a Company
  and make changes and payments (especially to complete the information
  required so that the Company shows up on the public pages),
  even if I have not yet paid my membership fee
  or even if the branding license fee has not been paid for the Company
  show a list of all the companies that I have an accepted application for.

  Background:

    Given the date is set to "2019-06-06"
    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following regions exist:
      | name      |
      | Stockholm |

    Given the following kommuns exist:
      | name     |
      | Alingsås |

    Given the following companies exist:
      | name     | company_number | email               | region    | kommun   | city      | visibility     |
      | Company1 | 5560360793     | hello@company-1.com | Stockholm | Alingsås | Harplinge | street_address |
      | Company2 | 2120000142     | hello@company-2.com | Stockholm | Alingsås | Harplinge | street_address |
      | Company3 | 6613265393     | hello@company-3.com | Stockholm | Alingsås | Harplinge | post_code      |
      | Company4 | 8025085252     | hello@company-4.com | Stockholm | Alingsås | Harplinge | post_code      |


    And the following users exist:
      | email                                  | admin | member |
      | rejected-user@company-1.com            |       | false  |
      | accepted-user@company-1.com            |       | false  |
      | accepted-user-many-cos@company-1.com   |       | false  |
      | rejected-member@company-1.com          |       | true   |
      | accepted-member@company-1.com          |       | true   |
      | accepted-member-many-cos@company-1.com |       | true   |
      | admin@shf.se                           | true  | false  |


    And the following business categories exist
      | name    |
      | Groomer |


    And the following applications exist:
      | user_email                             | company_number                     | categories | state    |
      | rejected-user@company-1.com            | 5560360793                         | Groomer    | rejected |
      | accepted-user@company-1.com            | 5560360793                         | Groomer    | accepted |
      | accepted-user-many-cos@company-1.com   | 5560360793, 2120000142, 6613265393 | Groomer    | accepted |
      | rejected-member@company-1.com          | 5560360793                         | Groomer    | rejected |
      | accepted-member@company-1.com          | 5560360793                         | Groomer    | accepted |
      | accepted-member-many-cos@company-1.com | 5560360793, 2120000142, 8025085252 | Groomer    | accepted |


    And the following payments exist
      | user_email                             | start_date | expire_date | payment_type | status | hips_id | company_number |
      | accepted-member@company-1.com          | 2019-10-1  | 2019-12-31  | member_fee   | betald | none    |                |
      | accepted-member-many-cos@company-1.com | 2019-01-01 | 2019-12-31  | member_fee   | betald | none    |                |
      | accepted-user@company-1.com            | 2017-01-01 | 2017-12-31  | branding_fee | betald | none    | 5560360793     |


  # ---------------------------------------------------------------------------------------------

  Scenario: User only has a rejected application for 1 company, so no companies are shown
    Given I am logged in as "rejected-user@company-1.com"
    When I am on the "landing" page
    Then I should not see t("my_company",count: "1.to_i")
    And I should not see t("my_company", count: "2.to_i")
    And I should not see "Company1"
    And I should not see "Company2"
    And I should not see "Company3"
    And I should not see "Company4"

  Scenario: User has 1 accepted application that lists 1 company
    Given I am logged in as "accepted-user@company-1.com"
    When I am on the "landing" page
    Then I should see t("my_company", count: "1.to_i")
    And I should see "Company1"
    And I should not see "Company2"
    And I should not see "Company3"
    And I should not see "Company4"


  Scenario: User has 1 accepted application that lists multiple companies
    Given I am logged in as "accepted-user-many-cos@company-1.com"
    When I am on the "landing" page
    Then I should see t("my_company", count: "2.to_i")
    And I should see "Company1"
    And I should see "Company2"
    And I should see "Company3"
    And I should not see "Company4"


  Scenario: Member has 1 accepted application that lists 1 company
    Given I am logged in as "accepted-member@company-1.com"
    When I am on the "landing" page
    Then I should see t("my_company", count: "1.to_i")
    And I should see "Company1"
    And I should not see "Company2"
    And I should not see "Company3"
    And I should not see "Company4"


  Scenario: Member has 1 accepted application that lists many companies
    Given I am logged in as "accepted-member-many-cos@company-1.com"
    When I am on the "landing" page
    Then I should see t("my_company", count: "2.to_i")
    And I should see "Company1"
    And I should see "Company2"
    And I should see "Company4"
    And I should not see "Company3"
