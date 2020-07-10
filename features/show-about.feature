Feature: Show a simple 'About' modal with info about the website

  Scenario: Show About modal
    Given I am logged out
    And I am on the home page
    When I click on t("about")
    Then I should see t("about_info.title")
    And I should see t("about_info.version")
