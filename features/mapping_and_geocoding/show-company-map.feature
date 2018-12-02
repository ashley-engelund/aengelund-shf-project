Feature: Visitor views a company and sees the map for it

  As a visitor
  So that I can how near or far a company is
  Show me the company location on a map on the company details page

  PivotalTracker https://www.pivotaltracker.com/story/show/133079479


  Background:

    Given the following users exist
      | email               | admin |
      | emma@happymutts.com |       |


    And the following regions exist:
      | name       |
      | Norrbotten |

    And the following kommuns exist:
      | name       |
      | Övertorneå |


    And the following companies exist:
      | name                 | company_number | email                  | region     | kommun     | city       | post_code | street_address    |
      | No More Snarky Barky | 5560360793     | snarky@snarkybarky.com | Norrbotten | Övertorneå | Övertorneå | 957 31    | Matarengivägen 24 |


    And the following business categories exist
      | name    |
      | Groomer |


    And the following applications exist:
      | user_email          | company_number | categories | state    |
      | emma@happymutts.com | 5560360793     | Groomer    | accepted |


  @selenium
  Scenario: Show the company on a map on the Company detail page
    Given I am on the page for company number "5560360793"
    And I should see the map
    And I should not see the Show Near Me control on the map
    And I should see 1 company markers on the map

