Feature: As an Admin
  So that I can use the exsiting Mailchimp system to share information with members
  I need to be able to export member names and emails to a csv file


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
      | first_name       | last_name        | user_email                     | company_number | state                 |
      | Emma             | Emmasdottir      | emma@happymutts.com            | 2120000142     | accepted              |
      | Hans             | Hansson          | hans@happymutts.com            | 2120000142     | accepted              |
      | Sam              | Samsson          | sam@snarkybarky.com            | 5560360793     | accepted              |
      | Lars             | Larson           | lars@snarkybarky.com           | 5560360793     | accepted              |
      | Wils             | Wilson           | wils@woof.com                  | 5569467466     | accepted              |
      | Kitty            | Kittydottir      | kitty@kitties.com              | 5906055081     | rejected              |
      | Meow             | Meowdottir       | meow@kitties.com               | 5906055081     | rejected              |
      | Under_Review     | Under_Reviewsson | under_review@kats.com          | 9697222900     | under_review          |
      | Ready for Review | Readydottir      | ready_for_review@kats.com      | 9697222900     | ready_for_review      |
      | Waiting for A    | Waitingson       | waiting_for_applicant@kats.com | 9697222900     | waiting_for_applicant |
      | New              | Newdottir        | new@kats.com                   | 9697222900     | new                   |



  Scenario: Visitor can't export
    Given I am Logged out
    When I am on the list applications page
    Then I should see t("errors.not_permitted")


  Scenario: User can't export
    Given I am logged in as "new@kats.com"
    When I am on the list applications page
    Then I should see t("errors.not_permitted")


  Scenario: Member can't export
    Given I am logged in as "emma@happymutts.com"
    When I am on the list applications page
    Then I should see t("errors.not_permitted")


  Scenario: Admin can export
    Given I am logged in as "admin@shf.se"
    And I am on the list applications page
    When I click on t("membership_applications.index.export") button
    Then I should see t("membership_applications.export.success")


  Scenario: All applications are exported
    Given I am logged in as "admin@shf.se"
    And I am on the list applications page
    When I click on t("membership_applications.index.export") button
    Then I should see t("membership_applications.export.success")
