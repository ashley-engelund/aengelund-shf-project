Feature: Pages load only the javascript needed

  So that pages load faster
  And so that we are not inadvertantly running javascript
  or connecting to servers on pages that do not require it
  Only load javascript that is required for each page


  Background:

    Given the following users exist
      | email               | admin | member |
      | emma@happymutts.se  |       | yes    |
      | applicant@bowwow.se |       |        |
      | visitor@example.com |       |        |
      | admin@shf.se        | yes   |        |

    And the following regions exist:
      | name       |
      | Norrbotten |

    And the following kommuns exist:
      | name       |
      | Övertorneå |


    And the following business categories exist
      | name    |
      | Groomer |


    And the following applications exist:
      | user_email          | company_number | categories | state    |
      | emma@happymutts.se  | 5560360793     | Groomer    | accepted |
      | applicant@bowwow.se | 5562252998     | Groomer    | new      |


    And the following companies exist:
      | Happy Mutts | 5560360793 | emma@happymutts.se |


    And the following payments exist
      | user_email         | start_date | expire_date | payment_type | status | hips_id | company_number |
      | emma@happymutts.se | 2017-10-1  | 2018-10-01  | member_fee   | betald | none    |                |
      | emma@happymutts.se | 2017-10-1  | 2018-10-01  | branding_fee | betald | none    | 5560360793     |


  @visitor
  Scenario: Hips.js is not loaded on the landing page for visitors but Google maps is
    Given I am on the "landing" page
    And I am Logged out
    Then I should see t("companies.index.h_companies_listed_below")
    And the page source should not have "hips.js" javascript in the header
    And the page source should have "maps.googleapis.com" javascript in the header


  @user
  Scenario: Hips.js is not loaded on the landing page for users but Google maps is
    Given I am on the "landing" page
    And I am logged in as "applicant@bowwow.se"
    Then the page source should not have "hips.js" javascript in the header
    And the page source should have "maps.googleapis.com" javascript in the header


  @member
  Scenario: Hips.js is not loaded on the landing page for members but Google maps is
    Given I am on the "landing" page
    And I am logged in as "emma@happymutts.se"
    Then the page source should not have "hips.js" javascript in the header
    And the page source should have "maps.googleapis.com" javascript in the header


  @admin
  Scenario: Hips.js is not loaded on the landing page for admin but Google maps is
    Given I am on the "landing" page
    And I am logged in as "admin@shf.se"
    Then the page source should not have "hips.js" javascript in the header
    And the page source should have "maps.googleapis.com" javascript in the header


  @user
  Scenario: Hips.js is loaded on the account page for users but Google maps, CKEditor are not
    Given I am logged in as "applicant@bowwow.se"
    And I am on the "user details" page for "applicant@bowwow.se"
    Then the page source should have "hips.js" javascript in the header
    And the page source should not have "maps.googleapis.com" javascript in the header


  @member
  Scenario: Hips.js is loaded on the account page for members but Google maps, CKEditor are not
    Given I am logged in as "emma@happymutts.se"
    And I am on the "user details" page for "emma@happymutts.se"
    Then the page source should have "hips.js" javascript in the header
    And the page source should not have "maps.googleapis.com" javascript in the header
    And the page source should not have "ckeditor.js" javascript in the header


  @admin
  Scenario: Hips.js is loaded on the account page for admins but Google maps, CKEditor are not
    Given I am logged in as "admin@shf.se"
    And I am on the "user details" page for "emma@happymutts.se"
    Then the page source should have "hips.js" javascript in the header
    And the page source should not have "maps.googleapis.com" javascript in the header
    And the page source should not have "ckeditor.js" javascript in the header


  @admin, @member
  Scenario Outline: CKEditor javascript is loaded for edit company page; hips.js should not be loaded
    Given I am logged in as "<user_email>"
    And I am on the edit company page for "5560360793"
    Then the page source should not have "hips.js" javascript in the header
    And the page source should have "ckeditor.js" javascript in the header
    And I am on the edit company page for "5560360793"
    Then the page source should not have "hips.js" javascript in the header
    And the page source should have "ckeditor.js" javascript in the header

    Scenarios:
      | user_email         |
      | admin@shf.se       |
      | emma@happymutts.se |


  @admin
  Scenario: CKEditor javascript is loaded for admin edit a SHF document, but not hips or Google maps
    Given I am logged in as "admin@shf.se"
    And I am on the "new SHF document" page
    And I fill in the translated form with data:
      | shf_documents.new.title | shf_documents.new.description |
      | Uploaded document       | some description              |
    And I choose a shf-document named "diploma.pdf" to upload
    And I click on t("submit") button
    And I am on the edit SHF document page for "Uploaded document"
    Then the page source should not have "hips.js" javascript in the header
    And the page source should not have "maps.googleapis.com" javascript in the header
    And the page source should have "ckeditor.js" javascript in the header


  @visitor
  Scenario: CKEditor javascript is not loaded on landing page or company view pages for a visitor (just to check a few)
    Given I am logged out
    And I am on the "landing" page
    Then the page source should not have "ckeditor.js" javascript in the header
    And I am on the page for company number "5560360793"
    Then the page source should not have "ckeditor.js" javascript in the header


