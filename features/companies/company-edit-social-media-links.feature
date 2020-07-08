Feature: Edit the social media urls (links) for a company

  Background:

    Given the Membership Ethical Guidelines Master Checklist exists

    Given the following users exist:
      | email            | admin | member |
      | member@mutts.com |       | true   |
      | admin@shf.se     | true  | true   |

    And the following companies exist:
      | name    | company_number | email              | facebook_url          | youtube_url          | instagram_url          |
      | Bowsers | 2120000142     | bowwow@bowsers.com | original-facebook-url | original-youtube-url | original-instagram-url |

    And the following applications exist:
      | user_email       | company_number | state    |
      | member@mutts.com | 2120000142     | accepted |

    Given the following payments exist
      | user_email       | start_date | expire_date | payment_type | status | hips_id | company_number |
      | member@mutts.com | 2019-1-1   | 2019-12-31  | member_fee   | betald | none    |                |
      | member@mutts.com | 2019-1-1   | 2019-12-31  | branding_fee | betald | none    | 2120000142     |

    Given the date is set to "2019-10-10"


  Scenario: All social media urls are changed successfully
    Given I am logged in as "member@mutts.com"
    And I am on the edit company page for "2120000142"
    Then I should see t("companies.form.facebook_url")
    And I should see t("companies.form.instagram_url")
    And I should see t("companies.form.youtube_url")
    When I fill in t("companies.form.facebook_url") with "http://facebook.com/example"
    And I fill in t("companies.form.youtube_url") with "http://youtube.com/example"
    And I fill in t("companies.form.instagram_url") with "http://instagram.com/example"
    And I click on t("submit")
    Then I should see t("companies.update.success")
    And I should see an icon with CSS class "fa-facebook" that is linked to "http://facebook.com/example"
    And I should see an icon with CSS class "fa-youtube" that is linked to "http://youtube.com/example"
    And I should see an icon with CSS class "fa-instagram" that is linked to "http://instagram.com/example"


  # -------------------------------------------------------------------
  # Javascript validation error message should show for invalid entries

  @selenium
  Scenario: Error message shows if Facebook url is invalid
    Given I am logged in as "member@mutts.com"
    And I am on the edit company page for "2120000142"
    When I fill in t("companies.form.facebook_url") with "http://blorf.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.instagram_url") with "http://instagram.com/example"
    Then I should see t("companies.form.bad_url_must_start_with", url_start: "http://facebook.com/")

  @selenium
  Scenario: Error message shows if Instagram url is invalid
    Given I am logged in as "member@mutts.com"
    And I am on the edit company page for "2120000142"
    When I fill in t("companies.form.instagram_url") with "http://blorf.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.youtube_url") with "http://youtube.com/example"
    Then I should see t("companies.form.bad_url_must_start_with", url_start: "http://instagram.com/")

  @selenium
  Scenario: Error message shows if YouTube url is invalid
    Given I am logged in as "member@mutts.com"
    And I am on the edit company page for "2120000142"
    When I fill in t("companies.form.youtube_url") with "http://blorf.com/example"
    # Need to move to another field in order to get the javascript validation error message to show
    And I fill in t("companies.form.facebook_url") with "http://facebook.com/example"
    Then I should see t("companies.form.bad_url_must_start_with", url_start: "http://youtube.com/")
