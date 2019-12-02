Feature: Admin sorts users

  As an admin
  I would like to sort users
  to quickly and easily find users I am interested in


  Background:

    Given the following users exist
      | first_name | last_name | email                           | admin | membership_number | member | date_membership_packet_sent | sign_in_count |  created_at |
      | John       | Adams     | ja@hotmail.com                  | false | 1                 | false  |                             |               |             |
      | Sarah      | Connor    | sconnor@example.com             | false | 2                 | true   |                             |               |             |
      | Lars       | Member    | lars-member@happymutts.com      | false | 101               | true   |                             |               |             |
      | Hannah     | Member    | hannah-member@happymutts.com    | false | 102               | true   |                             |               |             |
      | Former     | Member    | former-member@happymutts.com    | false |                   | false  |                             |               |             |
      | Luke       | Skywalker | luke@force.net                  | false | 14                | false  |                             |               |             |
      | admin      | admin     | admin@sverigeshundforetagare.se | true  | 3                 | false  |                             |               |             |


    And the following applications exist:
      | user_email                   | state                 | company_number |
      | ja@hotmail.com               | waiting_for_applicant | 0000000000     |
      | sconnor@example.com          | accepted              | 0000000000     |
      | luke@force.net               | rejected              | 0000000000     |
      | lars-member@happymutts.com   | accepted              | 5560360793     |
      | hannah-member@happymutts.com | accepted              | 5560360793     |

    And the following membership packets have been sent:
      | user_email                   | date_sent  |
      | sconnor@example.com          | 2019-03-01 |
      | lars-member@happymutts.com   | 2019-02-01 |
      | former-member@happymutts.com | 2018-02-01 |


    And I am logged in as "admin@sverigeshundforetagare.se"
    And I am on the "all users" page



  Scenario: Admin sorts users by email
    Given I am on the "all users" page
    When I click on t("users.users_list.email")
    Then I should see "luke@force.net" before "sconnor@example.com"


  Scenario: Admin sorts users by membership number
    When I click on t("users.users_list.membership_number")
    Then I should see "ja@hotmail.com" before "sconnor@example.com"
    Then I should see "sconnor@example.com" before "admin@sverigeshundforetagare.se"
    Then I should see "admin@sverigeshundforetagare.se" before "luke@force.net"
    When I click on t("users.users_list.membership_number")
    Then I should see "luke@force.net" before "admin@sverigeshundforetagare.se"
    Then I should see "admin@sverigeshundforetagare.se" before "sconnor@example.com"
    Then I should see "sconnor@example.com" before "ja@hotmail.com"


  Scenario: Sort by member packet sent status
    When I click on t("users.users_list.member_packet")
    Then I should see "sconnor@example.com" before "ja@hotmail.com"
    And I should see "lars-member@happymutts.com" before "ja@hotmail.com"
    And I should see "former-member@happymutts.com" before "ja@hotmail.com"

    # search in DESC order
    When I click on t("users.users_list.member_packet")
    Then I should see "luke@force.net" before "sconnor@example.com"
    And I should see "luke@force.net" before "lars-member@happymutts.com"
    And I should see "luke@force.net" before "former-member@happymutts.com"


  Scenario: Sort by when user was created ( = user registered)
    When I click on t("users.users_list.created")
    Then I should see "sconnor@example.com" before "ja@hotmail.com"
    And I should see "lars-member@happymutts.com" before "ja@hotmail.com"
    And I should see "former-member@happymutts.com" before "ja@hotmail.com"

    # search in DESC order
    When I click on t("users.users_list.created")
    Then I should see "luke@force.net" before "sconnor@example.com"
    And I should see "luke@force.net" before "lars-member@happymutts.com"
    And I should see "luke@force.net" before "former-member@happymutts.com"


  Scenario: Sort by number of logins
    When I click on t("users.users_list.logged_in_count")
    Then I should see "sconnor@example.com" before "ja@hotmail.com"
    And I should see "lars-member@happymutts.com" before "ja@hotmail.com"
    And I should see "former-member@happymutts.com" before "ja@hotmail.com"

    # search in DESC order
    When I click on t("users.users_list.logged_in_count")
    Then I should see "luke@force.net" before "sconnor@example.com"
    And I should see "luke@force.net" before "lars-member@happymutts.com"
    And I should see "luke@force.net" before "former-member@happymutts.com"


  Scenario: Sort by membership status
    When I click on t("users.users_list.member")
    Then I should see "sconnor@example.com" before "ja@hotmail.com"
    And I should see "lars-member@happymutts.com" before "ja@hotmail.com"
    And I should see "former-member@happymutts.com" before "ja@hotmail.com"

    # search in DESC order
    When I click on t("users.users_list.member")
    Then I should see "luke@force.net" before "sconnor@example.com"
    And I should see "luke@force.net" before "lars-member@happymutts.com"
    And I should see "luke@force.net" before "former-member@happymutts.com"
