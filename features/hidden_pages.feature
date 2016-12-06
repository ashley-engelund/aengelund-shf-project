Feature: Only members and admins can see members only (hidden) pages

  Background:

    Given the following users exists
      | email               | admin | is_member |
      | emma@happymutts.com |       | true      |
      | admin@shf.se        | true  | true      |
    
    
  Scenario: Visitor cannot see members only pages
    Given I am on the "static charter" page
    Then I should see "You are not permitted to see this page."

  Scenario: Member can see members only pages
    Given I am logged in as "emma@happymutts.com"
    And  I am on the "static charter" page
    Then I should see "Medlemsbeviset"
    Then I should not see "You are not permitted to see this page."

  Scenario: Admin can see members only pages
    Given I am logged in as "emma@happymutts.com"
    And  I am on the "static charter" page
    Then I should see "Medlemsbeviset"
    Then I should not see "You are not permitted to see this page."

      
    