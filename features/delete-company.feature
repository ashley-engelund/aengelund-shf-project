Feature: As an admin
  In order to keep the list of companies valid and up to date
  I need to be able to delete companies

  PT: https://www.pivotaltracker.com/story/show/138063171

  Only delete a company if it is not associated with any accepted MembershipApplications

  Only delete the business categories associated with a company
  if those business categories are not associated with any other companies.
  (Holds for each business category independently. So some might be deleted,
  and some might not.)


  Background:
    Given the following users exists
      | email                       | admin |
      | emma@happymutts.com         |       |
      | hans@happymutts.com         |       |
      | wils@woof.com               |       |
      | sam@snarkybarky.com         |       |
      | lars@snarkybarky.com        |       |
      | bob@bowsers.com             |       |
      | kitty@kitties.com           |       |
      | meow@kitties.com            |       |
      | under_review@kats.com       |       |
      | ready_for_review@kats.com   |       |
      | waiting_for_review@kats.com |       |
      | new@kats.com                |       |
      | admin@shf.se                | true  |

    And the following business categories exist
      | name        | description                     |
      | grooming    | grooming dogs from head to tail |
      | crooning    | crooning to dogs                |
      | training    | training dogs                   |
      | rehab       | physcial rehab for dogs         |
      | psychology  | mental rehab                    |
      | play-group  | play-group                      |
      | walking     | walking                         |
      | senior-play | senior-play                     |



    And the following regions exist:
      | name         |
      | Stockholm    |
      | Västerbotten |
      | Norrbotten   |


    # old_region is currently required so that company_complete? is true
    And the following companies exist:
      | name                 | company_number | email                 | region       | old_region |
      | Happy Mutts          | 2120000142     | woof@happymutts.com   | Stockholm    | Sweden     |
      | No More Snarky Barky | 5560360793     | bark@snarkybarky.com  | Stockholm    | Sweden     |
      | WOOF                 | 5569467466     | woof@woof.com         | Västerbotten | Sweden     |
      | Sad Sad Snarky Barky | 5562252998     | sad@sadmutts.com      | Norrbotten   | Sweden     |
      | Unassociated Company | 0000000000     | none@unassociated.com | Norrbotten   | Sweden     |
      | Kitties              | 5906055081     | kitties@kitties.com   | Stockholm    | Sweden     |
      | Kats                 | 9697222900     | kats@kats.com         | Stockholm    | Sweden     |


    And the following applications exist:
      | first_name       | user_email                     | company_number | state                 | category_name |
      | Emma             | emma@happymutts.com            | 2120000142     | accepted              | grooming      |
      | Hans             | hans@happymutts.com            | 2120000142     | accepted              | training      |
      | Sam              | sam@snarkybarky.com            | 5560360793     | rejected              | crooning      |
      | Lars             | lars@snarkybarky.com           | 5560360793     | rejected              | rehab         |
      | Wils             | wils@woof.com                  | 5569467466     | accepted              | walking       |
      | Kitty            | kitty@kitties.com              | 5906055081     | rejected              | play-group    |
      | Meow             | meow@kitties.com               | 5906055081     | rejected              | senior-play   |
      | Under_Review     | under_review@kats.com          | 9697222900     | under_review          | psychology    |
      | Ready for Review | ready_for_review@kats.com      | 9697222900     | ready_for_review      | psychology    |
      | Waiting for A    | waiting_for_applicant@kats.com | 9697222900     | waiting_for_applicant | psychology    |
      | New              | new@kats.com                   | 9697222900     | new                   | psychology    |



  # --- policy (permission)

  Scenario: A User cannot delete a company
    Given I am logged in as "bob@bowsers.com"
    When I am on the "all companies" page
    Then I should not see button t("delete")

  Scenario: A Member cannot delete a company
    Given I am logged in as "emma@happymutts.com"
    When I am on the "all companies" page
    Then I should not see t("delete")

  Scenario: A Member cannot delete their company
    Given I am logged in as "emma@happymutts.com"
    When I am the page for company number "5569467466"
    Then I should not see t("delete")

  Scenario: An Admin has the delete button on the companies list page
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should see t("delete")


  # ----  Categories --------

  Scenario: Admin deletes a company with no membership applications and no categories
    Given I am logged in as "admin@shf.se"
    When I am on the "all companies" page
    Then I should see "5" companies
    When I click the t("delete") action for the row with "Unassociated Company"
    Then I should see t("companies.destroy.success")
    And I should not see "Unassociated Company"
    And I should see "4" companies


  # ---- MembershipApplications -----

  Scenario: Admin deletes a company that has applications with that company number, but are not accepted or rejected
    Given I am logged in as "admin@shf.se"
    When I am on the "business categories" page
    Then I should see "5" business categories
    When I am on the "landing" page
    Then I should see "11" applications
    When I am on the "all companies" page
    Then I should see "5" companies
    When I click the t("delete") action for the row with "Kats"
    Then I should see "warning: associated with 2 rejected applications. Are you sure you want to delete the company?"
    And I click on "YES"
    Then I should see t("companies.destroy.success")
    And I should not see "Kats"
    And I should see "4" companies
    When I am on the "business categories" page
    Then I should see "5" business categories
    When I am on the "landing" page
    Then I should see "11" applications


  Scenario: Admin cannot delete a company with 2 (accepted) membership applications

  Scenario: Admin cannot delete a company with 1 accepted and 1 rejected membership application


  Scenario: Admin deletes a company with 2 rejected membership applications associated with it
    Given I am logged in as "admin@shf.se"
    When I am on the "business categories" page
    Then I should see "5" business categories
    When I am on the "landing" page
    Then I should see "11" applications
    When I am on the "all companies" page
    Then I should see "5" companies
    When I click the t("delete") action for the row with "Kitties"
    Then I should see "warning: associated with 2 rejected applications. Are you sure you want to delete the company?"
    And I click on "YES"
    Then I should see t("companies.destroy.success")
    And I should not see "Kitties"
    And I should see "4" companies
    When I am on the "business categories" page
    Then I should see "5" business categories
    When I am on the "landing" page
    Then I should see "11" applications


  Scenario: Admin deletes a company with 1 rejected membership application and 2 categories (only with it)
    Given I am logged in as "admin@shf.se"
    When I am on the "business categories" page
    Then I should see "5" business categories
    When I am on the "landing" page
    Then I should see "11" applications
    When I am on the "all companies" page
    Then I should see "5" companies
    When I click the t("delete") action for the row with "No More Snarky Barky"
    Then I should see "warning: associated with 2 categories. Are you sure you want to delete the company?"
    And I click on "YES"
    Then I should see t("companies.destroy.success")
    And I should not see "No More Snarky Barky"
    And I should see "4" companies
    When I am on the "business categories" page
    Then I should see "5" business categories
    When I am on the "landing" page
    Then I should see "10" applications


  Scenario: Admin deletes a company with 1 rejected membership app, 2 categories (only 1 associated with it)


